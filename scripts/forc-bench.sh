#!/usr/bin/env bash

# Benchmark runner for the lightweight, convention-based Sway benchmarks (see
# `benchmarks/README.md`).
#
# Sway has no native benchmarking (`forc bench`), so benchmarks are encoded as
# `forc test` unit tests following a naming convention:
#
#     bench__<group>__<name>       a benchmark
#     baseline[__<group>[__<name>]] its baseline (fixture + keep overhead)
#
# The real cost of a benchmark is `gas(bench) - gas(<matching baseline>)`, where
# the matching baseline is found by most-specific-prefix match (walking the name
# from the most specific segment down to the bare `baseline` fallback). This
# script runs the tests, computes those net costs, and prints them in one or
# more formats.
#
# Usage:
#
#     ./scripts/forc-bench.sh -p <project> [options]
#
# Options:
#
#     -p, --path <project>          Path to the benchmark project (required),
#                                   e.g. `benchmarks/src16`.
#         --experimental <flags>    Forwarded to `forc test` as
#                                   `--experimental <flags>` (optional).
#         --no-experimental <flags> Forwarded to `forc test` as
#                                   `--no-experimental <flags>` (optional).
#     -f, --format <fmt>...         One or more of: raw csv ascii md json
#                                   (default: raw). May be repeated or given as
#                                   a space-separated list, e.g. `-f ascii json`.
#     -h, --help                    Show this help.
#
# Formats (the benchmark is pretty-printed as `<group>::<name>` everywhere):
#
#     raw    The raw `forc test` output, verbatim.
#     csv    `bench,gas` CSV (with header), gas being the net cost.
#     ascii  A `Bench | Gas` ASCII table.
#     md     A `Bench | Gas` Markdown table.
#     json   `[{"bench": "<group>::<name>", "gas": <gas>}, ...]`.
#
# Diagnostics (version warnings, progress) go to stderr, so stdout carries only
# the requested format(s) and stays pipe-clean for a single machine-readable
# format. When more than one format is requested, each is preceded by a
# `===== <FORMAT> =====` header.
#
# Before reporting, the runner enforces the benchmark conventions: every
# `bench`/`baseline` test name must be well-formed, every benchmark must resolve
# to a baseline, and every `fixture_*` function must be marked `#[inline(never)]`.
# On any violation it prints the offenders to stderr and exits with code 3.
#
# In the end this invokes:
#
#     forc test --release --terse --path <project> \
#         [--experimental <flags>] [--no-experimental <flags>]

set -u

# The expected `forc` version. If the installed `forc` differs, a warning is
# printed (to stderr) before running the benchmarks.
FORC_VERSION="0.71.2"

VALID_FORMATS="raw csv ascii md json"

usage() {
    # Print the leading comment block (the usage text) without the shebang.
    sed -n '3,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

err() {
    echo "ERROR: $*" >&2
}

require_value() {
    # require_value <flag> <count-of-remaining-args>
    if [[ "$2" -lt 2 ]]; then
        err "missing value for $1"
        exit 2
    fi
}

PATH_ARG=""
EXPERIMENTAL=""
NO_EXPERIMENTAL=""
FORMATS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            require_value "$1" "$#"
            PATH_ARG="$2"
            shift 2
            ;;
        --experimental)
            require_value "$1" "$#"
            EXPERIMENTAL="$2"
            shift 2
            ;;
        --no-experimental)
            require_value "$1" "$#"
            NO_EXPERIMENTAL="$2"
            shift 2
            ;;
        -f|--format)
            shift
            # Consume following tokens until the next flag (so `-f ascii json`
            # works), while also supporting repeated `-f` flags.
            if [[ $# -eq 0 || "$1" == -* ]]; then
                err "missing value for --format"
                exit 2
            fi
            while [[ $# -gt 0 && "$1" != -* ]]; do
                FORMATS+=("$1")
                shift
            done
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            err "unknown argument: $1"
            echo >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ -z "${PATH_ARG}" ]]; then
    err "missing required --path <project>"
    echo >&2
    usage >&2
    exit 2
fi

# Default to `raw` when no format is requested.
if [[ ${#FORMATS[@]} -eq 0 ]]; then
    FORMATS=("raw")
fi

# Validate formats and drop duplicates while preserving first-seen order.
unique_formats=()
for fmt in "${FORMATS[@]}"; do
    case " ${VALID_FORMATS} " in
        *" ${fmt} "*) ;;
        *)
            err "invalid format '${fmt}'. Valid formats: ${VALID_FORMATS}."
            exit 2
            ;;
    esac
    seen=false
    for u in "${unique_formats[@]:-}"; do
        [[ "${u}" == "${fmt}" ]] && seen=true && break
    done
    [[ "${seen}" == false ]] && unique_formats+=("${fmt}")
done
FORMATS=("${unique_formats[@]}")

if ! command -v forc >/dev/null 2>&1; then
    err "'forc' was not found in PATH. Please install forc ${FORC_VERSION}."
    exit 1
fi

installed_forc="$(forc --version 2>/dev/null | awk '{print $NF}')"
if [[ "${installed_forc}" != "${FORC_VERSION}" ]]; then
    echo "WARNING: Expected forc version ${FORC_VERSION}, but found '${installed_forc}'." >&2
    echo "         Benchmarks are measured with forc ${FORC_VERSION}; results might differ." >&2
    echo >&2
fi

FORC_ARGS=(test --release --terse --path "${PATH_ARG}")
[[ -n "${EXPERIMENTAL}" ]] && FORC_ARGS+=(--experimental "${EXPERIMENTAL}")
[[ -n "${NO_EXPERIMENTAL}" ]] && FORC_ARGS+=(--no-experimental "${NO_EXPERIMENTAL}")

out_file="$(mktemp)"
trap 'rm -f "${out_file}"' EXIT

echo "Running: forc ${FORC_ARGS[*]}" >&2
forc "${FORC_ARGS[@]}" > "${out_file}" 2>&1
status=$?

if [[ ${status} -ne 0 ]]; then
    err "'forc test' failed (exit ${status}). Output:"
    cat "${out_file}" >&2
    exit "${status}"
fi

# awk program that parses the captured `forc test` output, computes the net gas
# per benchmark (bench minus its most-specific baseline), and prints one format.
read -r -d '' AWK_PROG <<'AWK'
function chop(s,   i, last) {
    # Drop the last `_`-delimited token (and the `_`). Used to walk a baseline
    # name from most specific to least specific.
    last = 0
    for (i = 1; i <= length(s); i++)
        if (substr(s, i, 1) == "_") last = i
    if (last == 0) return s
    return substr(s, 1, last - 1)
}

function resolve(bench,   cand) {
    # Most-specific-prefix match against the known baselines.
    cand = bench
    sub(/^bench__/, "baseline__", cand)
    while (index(cand, "_") > 0) {
        if (cand in basegas) return basegas[cand]
        cand = chop(cand)
    }
    if (cand in basegas) return basegas[cand]   # the bare `baseline`
    return "NONE"
}

function prettify(bench,   s) {
    # `bench__<group>__<name>` -> `<group>::<name>`.
    s = bench
    sub(/^bench__/, "", s)
    sub(/__/, "::", s)
    return s
}

function rep(n, ch,   i, s) {
    s = ""
    for (i = 0; i < n; i++) s = s ch
    return s
}

{
    line = $0
    gsub(/\033\[[0-9;]*m/, "", line)   # strip ANSI color codes
    $0 = line                          # re-split into fields
}

$1 == "test" && $4 == "ok" && $NF == "gas)" {
    name = $2
    gas = $(NF - 1) + 0
    if (name ~ /^bench__/) {
        order[++n] = name
        benchgas[name] = gas
    } else if (name == "baseline" || name ~ /^baseline__/) {
        basegas[name] = gas
    }
}

END {
    # Compute net costs. A negative net means the operation is effectively free
    # (the subtraction landed on the measurement floor), so report it as 0.
    maxbench = length("Bench")
    maxgas = length("Gas")
    for (i = 1; i <= n; i++) {
        b = order[i]
        base = resolve(b)
        if (base == "NONE") {
            print "WARNING: no baseline found for " b "; using raw gas." > "/dev/stderr"
            net = benchgas[b]
        } else {
            net = benchgas[b] - base
        }
        if (net < 0) net = 0
        pretty[i] = prettify(b)
        value[i] = net
        if (length(pretty[i]) > maxbench) maxbench = length(pretty[i])
        if (length(net "") > maxgas) maxgas = length(net "")
    }

    # Sort indices by pretty name (insertion sort; n is small). `raw` is printed
    # verbatim elsewhere and keeps source order; every other format is sorted.
    for (i = 1; i <= n; i++) ord[i] = i
    for (i = 2; i <= n; i++) {
        key = ord[i]
        j = i - 1
        while (j >= 1 && pretty[ord[j]] > pretty[key]) {
            ord[j + 1] = ord[j]
            j--
        }
        ord[j + 1] = key
    }

    if (fmt == "csv") {
        print "bench,gas"
        for (k = 1; k <= n; k++) print pretty[ord[k]] "," value[ord[k]]
    } else if (fmt == "md") {
        print "| Bench | Gas |"
        print "| --- | --: |"
        for (k = 1; k <= n; k++) printf("| %s | %d |\n", pretty[ord[k]], value[ord[k]])
    } else if (fmt == "json") {
        printf("[")
        for (k = 1; k <= n; k++) {
            printf("%s\n  {\"bench\": \"%s\", \"gas\": %d}", (k == 1 ? "" : ","), pretty[ord[k]], value[ord[k]])
        }
        printf("%s]\n", (n == 0 ? "" : "\n"))
    } else if (fmt == "ascii") {
        border = "+" rep(maxbench + 2, "-") "+" rep(maxgas + 2, "-") "+"
        print border
        printf("| %-*s | %*s |\n", maxbench, "Bench", maxgas, "Gas")
        print border
        for (k = 1; k <= n; k++)
            printf("| %-*s | %*d |\n", maxbench, pretty[ord[k]], maxgas, value[ord[k]])
        print border
    }
}
AWK

# awk program that validates benchmark/baseline test names. Prints one offending
# name per line (to stdout); a benchmark must be `bench__<group>__<name>` and a
# baseline `baseline`, `baseline__<group>`, or `baseline__<group>__<name>`.
read -r -d '' NAME_CHECK_AWK <<'AWK'
function valid_bench(n,   rest, p, g, nm) {
    if (n !~ /^bench__/) return 0
    rest = substr(n, 8)            # drop the leading "bench__"
    p = index(rest, "__")
    if (p == 0) return 0           # no <group>__<name> separator
    g = substr(rest, 1, p - 1)
    nm = substr(rest, p + 2)
    return (length(g) > 0 && length(nm) > 0)
}
{ line = $0; gsub(/\033\[[0-9;]*m/, "", line); $0 = line }
$1 == "test" && $4 == "ok" && $NF == "gas)" {
    name = $2
    if (name ~ /^bench/) {
        if (!valid_bench(name)) print name "  (expected bench__<group>__<name>)"
    } else if (name ~ /^baseline/) {
        if (name != "baseline" && name !~ /^baseline__.+/)
            print name "  (expected baseline, baseline__<group>, or baseline__<group>__<name>)"
    }
}
AWK

# awk program that checks every benchmark resolves to a baseline (by the same
# most-specific-prefix walk the formatter uses, down to the bare `baseline`
# fallback). Prints each benchmark with no matching baseline (to stdout).
read -r -d '' BASELINE_CHECK_AWK <<'AWK'
function valid_bench(n,   rest, p, g, nm) {
    if (n !~ /^bench__/) return 0
    rest = substr(n, 8)
    p = index(rest, "__")
    if (p == 0) return 0
    g = substr(rest, 1, p - 1)
    nm = substr(rest, p + 2)
    return (length(g) > 0 && length(nm) > 0)
}
function chop(s,   i, last) {
    last = 0
    for (i = 1; i <= length(s); i++)
        if (substr(s, i, 1) == "_") last = i
    if (last == 0) return s
    return substr(s, 1, last - 1)
}
function has_baseline(bench,   cand) {
    cand = bench
    sub(/^bench__/, "baseline__", cand)
    while (index(cand, "_") > 0) {
        if (cand in base) return 1
        cand = chop(cand)
    }
    return (cand in base)          # the bare `baseline`
}
{ line = $0; gsub(/\033\[[0-9;]*m/, "", line); $0 = line }
$1 == "test" && $4 == "ok" && $NF == "gas)" {
    name = $2
    if (valid_bench(name)) benches[++nb] = name
    else if (name == "baseline" || name ~ /^baseline__/) base[name] = 1
}
END {
    for (i = 1; i <= nb; i++)
        if (!has_baseline(benches[i])) print benches[i]
}
AWK

# awk program that checks every `fixture_*` function is marked `#[inline(never)]`.
# It accumulates the attribute lines (`#[...]`) directly above a definition and,
# when it reaches a `fn fixture_...`, verifies one of them is `#[inline(never)]`.
# Prints `<file>:<line>: <def>` for each offending fixture (to stdout).
read -r -d '' FIXTURE_CHECK_AWK <<'AWK'
/^[[:space:]]*#\[/ { attrs = attrs $0; next }   # attribute line: accumulate
/^[[:space:]]*$/   { next }                     # blank line: keep accumulated attrs
{
    if ($0 ~ /^[[:space:]]*(pub[[:space:]]+)?fn[[:space:]]+fixture_/) {
        if (attrs !~ /#\[inline\(never\)\]/) {
            def = $0
            sub(/^[[:space:]]+/, "", def)
            printf("%s:%d: %s\n", FILENAME, FNR, def)
        }
    }
    attrs = ""                                  # any code line resets the attrs
}
AWK

# Enforce the benchmark conventions before reporting (see `benchmarks/README.md`).
name_violations="$(awk "${NAME_CHECK_AWK}" "${out_file}")"
baseline_violations="$(awk "${BASELINE_CHECK_AWK}" "${out_file}")"

sw_files=()
while IFS= read -r -d '' f; do
    sw_files+=("${f}")
done < <(find "${PATH_ARG%/}/src" -type f -name '*.sw' -print0 2>/dev/null)

fixture_violations=""
if [[ ${#sw_files[@]} -gt 0 ]]; then
    fixture_violations="$(awk "${FIXTURE_CHECK_AWK}" "${sw_files[@]}")"
fi

if [[ -n "${name_violations}" || -n "${baseline_violations}" || -n "${fixture_violations}" ]]; then
    err "benchmark convention violations found:"
    if [[ -n "${name_violations}" ]]; then
        echo >&2
        echo "  Malformed benchmark/baseline test names:" >&2
        while IFS= read -r v; do echo "    ${v}" >&2; done <<< "${name_violations}"
    fi
    if [[ -n "${baseline_violations}" ]]; then
        echo >&2
        echo "  Benchmarks with no matching baseline (need a baseline, e.g. the bare 'baseline'):" >&2
        while IFS= read -r v; do echo "    ${v}" >&2; done <<< "${baseline_violations}"
    fi
    if [[ -n "${fixture_violations}" ]]; then
        echo >&2
        echo "  Fixtures ('fixture_*' functions) must be marked '#[inline(never)]':" >&2
        while IFS= read -r v; do echo "    ${v}" >&2; done <<< "${fixture_violations}"
    fi
    echo >&2
    exit 3
fi

multiple=false
[[ ${#FORMATS[@]} -gt 1 ]] && multiple=true

for fmt in "${FORMATS[@]}"; do
    if [[ "${multiple}" == true ]]; then
        echo "===== ${fmt} ====="
    fi
    if [[ "${fmt}" == "raw" ]]; then
        cat "${out_file}"
    else
        awk -v fmt="${fmt}" "${AWK_PROG}" "${out_file}"
    fi
    [[ "${multiple}" == true ]] && echo
done

# The loop's last statement (`[[ ... ]] && echo`) can leave a non-zero exit code
# when only a single format is requested. Exit explicitly so callers (e.g. `just`)
# don't see a spurious failure.
exit 0
