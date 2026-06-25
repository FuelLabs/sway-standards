#!/usr/bin/env bash

# Shared implementation behind `build-standards.sh` and `build-examples.sh`.
#
# Usage: build.sh <subdir> <label> [extra `forc build` args]
#
#   <subdir>  Directory under the repository root whose immediate subdirectories
#             are the projects/workspaces to build (e.g. `standards`, `examples`).
#   <label>   Singular noun used in the printed messages (e.g. `standard`).
#
# Builds, in parallel, every immediate subdirectory of `<subdir>` that contains
# a Forc.toml. For examples this is a workspace Forc.toml, in which case the
# whole workspace (all its member projects) is built.
#
# Any further arguments are forwarded as-is to `forc build`, e.g.:
#
#     build.sh standards standard --release --experimental dynamic_storage
#
# Each project is built concurrently and only a concise per-project result is
# printed live (green check mark on success, red cross mark on failure). The
# full output of any failing build is printed at the end, before the final
# statistics.
#
# The script continues even when individual builds fail, and exits with a
# non-zero code at the end if any build failed.
#
# Concurrency defaults to half of the available CPU cores (at least 1) and can
# be overridden via the PARALLEL_JOBS environment variable.

set -u

if [[ $# -lt 2 ]]; then
    echo "ERROR: usage: build.sh <subdir> <label> [extra forc build args]" >&2
    exit 2
fi

# The expected `forc` version. If the installed `forc` differs, a warning is
# printed before and after building all the projects.
FORC_VERSION="0.70.2"

SUBDIR="$1"
LABEL="$2"
shift 2

# Resolve paths relative to the repository root, regardless of the current
# working directory from which the script is called.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_DIR="${REPO_ROOT}/${SUBDIR}"

# The additional arguments forwarded to `forc build`.
FORC_BUILD_ARGS=("$@")

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_forc_version() {
    local installed
    installed="$(forc --version 2>/dev/null | awk '{print $NF}')"

    if [[ "${installed}" != "${FORC_VERSION}" ]]; then
        echo "WARNING: Expected forc version ${FORC_VERSION}, but found '${installed}'."
        echo "         The ${LABEL}s are tested with forc ${FORC_VERSION}. Builds might behave unexpectedly."
        echo
    fi
}

if ! command -v forc >/dev/null 2>&1; then
    echo "ERROR: 'forc' was not found in PATH. Please install forc ${FORC_VERSION}."
    exit 1
fi

check_forc_version

# Collect the projects to build. Only directories that actually contain a
# Forc.toml are considered. The glob expands in sorted order, which makes the
# final pass/fail reporting deterministic regardless of build finish order.
project_names=()
project_dirs=()
for project_dir in "${TARGET_DIR}"/*/; do
    [[ -f "${project_dir}Forc.toml" ]] || continue
    project_names+=("$(basename "${project_dir}")")
    project_dirs+=("${project_dir}")
done

# Default concurrency to half of the available cores (at least 1) to leave
# headroom on the machine. Can be overridden via the PARALLEL_JOBS env var.
# `nproc` is Linux; `sysctl -n hw.ncpu` is the macOS equivalent.
cores="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(( cores / 2 ))}"
(( PARALLEL_JOBS < 1 )) && PARALLEL_JOBS=1

# `wait -n` (wait for any single job to finish) requires Bash >= 4.3.
# macOS ships Bash 3.2, so fall back to polling there.
if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3) )); then
    HAVE_WAIT_N=true
else
    HAVE_WAIT_N=false
fi

wait_for_slot() {
    if [[ "${HAVE_WAIT_N}" == true ]]; then
        wait -n 2>/dev/null || true
    else
        sleep 0.2
    fi
}

logs_dir="$(mktemp -d)"
trap 'rm -rf "${logs_dir}"' EXIT

build_one() {
    local project_name="$1"
    local project_dir="$2"
    local log_file="${logs_dir}/${project_name}.log"

    if forc build --path "${project_dir}" "${FORC_BUILD_ARGS[@]}" > "${log_file}" 2>&1; then
        printf '%b %s\n' "${GREEN}✓${NC}" "${project_name}"
        echo "pass" > "${logs_dir}/${project_name}.status"
    else
        printf '%b %s\n' "${RED}✗${NC}" "${project_name}"
        echo "fail" > "${logs_dir}/${project_name}.status"
    fi
}

echo "Building ${#project_names[@]} ${LABEL}(s) in parallel (up to ${PARALLEL_JOBS} at a time)..."
echo

start_time=${SECONDS}

for i in "${!project_names[@]}"; do
    # Throttle: wait for a free slot before launching the next build.
    # Note: `jobs` reads Bash's job table, which is maintained even in
    # non-interactive shells where job control (monitor mode) is off, as is the
    # case when these scripts run under `just`. So `jobs -rp` reliably counts
    # the running background builds here and the limit is enforced; this does
    # not depend on monitor mode (`set -m`) being enabled.
    while (( $(jobs -rp | wc -l) >= PARALLEL_JOBS )); do
        wait_for_slot
    done
    build_one "${project_names[$i]}" "${project_dirs[$i]}" &
done

# Wait for all remaining builds to finish.
wait

elapsed=$(( SECONDS - start_time ))

# Build pass/fail lists in the stable (sorted) project order.
succeeded=()
failed=()
for project_name in "${project_names[@]}"; do
    if [[ "$(cat "${logs_dir}/${project_name}.status" 2>/dev/null)" == "pass" ]]; then
        succeeded+=("${project_name}")
    else
        failed+=("${project_name}")
    fi
done

# Print the full output of any failing build to aid debugging.
if [[ ${#failed[@]} -gt 0 ]]; then
    echo
    echo "================================================"
    echo "Output of failing builds:"
    echo "================================================"
    for project_name in "${failed[@]}"; do
        echo
        echo "==> ${project_name}"
        cat "${logs_dir}/${project_name}.log" 2>/dev/null
    done
fi

echo

check_forc_version

echo "Total build time: $(( elapsed / 60 ))m $(( elapsed % 60 ))s."

if [[ ${#failed[@]} -eq 0 ]]; then
    echo "SUCCESS: Built ${#succeeded[@]} ${LABEL}(s)."
    exit 0
else
    echo "FAILURE: ${#failed[@]} of ${#project_names[@]} ${LABEL}(s) failed to build:"
    for project_name in "${failed[@]}"; do
        echo "  - ${project_name}"
    done
    exit 1
fi
