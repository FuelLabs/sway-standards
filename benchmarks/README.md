# Benchmarks

Sway has no native benchmarking support (there is no `forc bench`). These
benchmarks are a lightweight, convention-based form of benchmarking built on top
of Sway unit tests (`forc test`). `forc test` reports the gas consumed by
each test, and we use that number, together with a per-benchmark *baseline*, to
isolate the gas cost of the code under measurement.

## Running

Use the benchmark runner. It runs the tests, subtracts each benchmark's
baseline, and prints the net costs (e.g. for SRC16):

```sh
just b -p benchmarks/src16 -f ascii
# or, equivalently:
./scripts/forc-bench.sh -p benchmarks/src16 -f ascii
```

The runner always builds in `--release` (benchmarks measure optimized code;
debug numbers are not meaningful) and runs `forc test --terse` under the hood.
Prefer it over a bare `forc test`, which reports per-test gas *before* the
baseline subtraction.

Pass one or more output formats with `-f`/`--format`:

- `raw` — the raw `forc test` output, verbatim (per-test gas, source order).
- `csv` — `bench,gas` CSV.
- `ascii` — an ASCII `Bench | Gas` table.
- `md` — a Markdown `Bench | Gas` table.
- `json` — `[{"bench": "<group>::<name>", "gas": <gas>}, ...]`.

Every format except `raw` reports the **net** cost, with benchmarks pretty-printed
as `<group>::<name>` and sorted by that name. See
`./scripts/forc-bench.sh --help` for all options (including `--experimental` /
`--no-experimental`).

### Convention checks

Before reporting, the runner enforces the conventions described below and fails
(exit code 3, offenders printed to stderr) if any are violated:

- every `bench`/`baseline` test name is well-formed (a benchmark must be
  `bench__<group>__<name>`; a baseline `baseline`, `baseline__<group>`, or
  `baseline__<group>__<name>`);
- every benchmark resolves to a baseline (some baseline must match, down to the
  bare `baseline` fallback);
- every `fixture_*` function is marked `#[inline(never)]`.

This keeps a malformed name or a forgotten attribute from silently corrupting a
measurement.

### What the reported gas means

The net cost of a benchmark is:

```
cost(bench__<x>) = gas(bench__<x>) - gas(<the matching baseline>)
```

The subtraction removes the unavoidable overhead of building the inputs
(fixtures) and of "keeping" the result (see [Keeping results](#keeping-results)),
leaving only the gas of the operation under measurement. The runner does this
for you.

A net cost of `0` means the operation is effectively **free**: the baseline
already accounts for everything the benchmark does, so the subtraction lands on
the measurement floor. (The raw subtraction can even come out slightly negative
due to tiny asymmetries; the runner clamps such values to `0`.) This is the
expected result for no-op passthroughs (e.g. an encoder that just returns its
`b256` argument).

## Project layout

Each standard's benchmarks are a separate Forc library package under
`benchmarks/`. Within a package, the source is split into one module per
benchmarked type, plus shared scaffolding:

```text
benchmarks/
├── benchmarking/              # shared library: keep, keep_ref_type, keep_copy_type
│   └── src/benchmarking.sw
└── src16/
    ├── Forc.toml              # depends on `benchmarking` and the standard (`src16`)
    └── src/
        ├── src16.sw           # root entry: only `pub mod ...;` lines
        ├── common.sw          # global `baseline` + cross-cutting fixtures
        ├── src16_domain.sw    # one module per benchmarked type ...
        ├── eip712_domain.sw
        ├── src16_payload.sw
        └── data_encoder.sw
```

A module's name matches the benchmark `<group>` it contains. The group is still
repeated in every test name because `forc test` reports only the bare function
name, not its module path — without the group, identically-named tests in
different modules would collide.

The `keep` helpers live in the shared `benchmarking` library and are reused by
every benchmark package through a path dependency in `Forc.toml`:

```toml
[dependencies]
benchmarking = { path = "../benchmarking" }
src16 = { path = "../../standards/src16" }
```

Each module imports them with `use benchmarking::*;`.

A few Sway module rules worth noting:

- The root entry contains only `pub mod <module>;` lines. Modules must be `pub`
  so that sibling modules can import from them.
- A module imports an item from a sibling using an absolute path from the package
  root: `use ::common::fixture_create_buffer;`. Items shared across modules
  (fixtures, etc.) are therefore marked `pub`.
- The global fallback `baseline` **cannot** be shared via the `benchmarking`
  library: `forc test` does not run tests defined in dependency packages. It
  lives in each package's `common` module instead.

## Naming conventions

Every benchmark and baseline is a `#[test]`. The test name encodes everything,
using `__` (double underscore) as the segment separator:

- A **benchmark** is named `bench__<group>__<name>`, where both `<group>` and
  `<name>` are mandatory. `<group>` and `<name>` may each contain `_` for further
  qualification (e.g. `bench__some_group__some_name_a_b_c`).
- A **baseline** measures the overhead (fixtures + keep) of one or more
  benchmarks. It is named `baseline`, `baseline__<group>`,
  `baseline__<group>__<name>`, etc.

### Baseline resolution

A benchmark's baseline is chosen by **most-specific prefix match**. Given a
benchmark, walk its name segments from the most specific to the least specific
and pick the first baseline that exists. The bare `baseline` is the final
fallback.

For example, given the benchmark `bench__group__name_a_b_c` and the baselines
`baseline`, `baseline__group`, and `baseline__group__name_a`:

| Benchmark                       | Chosen baseline             |
| ------------------------------- | --------------------------- |
| `bench__group__name_a_b_c`      | `baseline__group__name_a`   |
| `bench__group__name_d`          | `baseline__group`           |
| `bench__other_group__name`      | `baseline`                  |

This lets several benchmarks that share the same fixtures share a single
baseline, while still allowing a more specific baseline when one benchmark needs
different fixtures.

## Fixtures

Inputs are built by helper functions prefixed with `fixture_`. Fixtures **must**
be marked `#[inline(never)]`. This guarantees the input-building cost is a real,
non-eliminable function call that appears identically in both the benchmark and
its baseline, and therefore cancels out in the subtraction.

```sway
#[inline(never)]
fn fixture_create_src16_domain() -> SRC16Domain { /* ... */ }
```

A baseline runs exactly the same fixtures as its benchmark(s), but does **not**
run the operation under measurement.

A fixture used by more than one module is marked `pub` and imported via an
absolute path (see [Project layout](#project-layout)). Cross-cutting fixtures
that belong to no single type (e.g. an empty `Buffer`) live in `common`.

## Keeping results

The compiler will optimize away ("dead-code eliminate") any computation whose
result is unused. If that happens, the benchmark measures nothing. We therefore
always **keep** the result so it cannot be eliminated, using the `keep` helper
from the shared `benchmarking` library:

```sway
#[inline(never)]
pub fn keep<T>(_t: T) {}
```

`keep` is `#[inline(never)]`, so passing a value to it forces the value — and the
computation that produced it — to be materialized.

Do **not** rely on `let _ = ...` to keep a result. It happens to prevent
elimination today, but that is an implementation detail of the current compiler;
it may change, and it may already be wrong in some cases. **Always `keep`.**

### `keep_ref_type` and `keep_copy_type` in baselines

The baseline must mirror the benchmark's `keep` so that the keep cost cancels.
Since `keep` is empty, its only cost is *passing the argument*, and there are
exactly two cases:

- **Reference types** — `b256`, `u256`, `String`, arrays, tuples, and any
  struct — are passed as a pointer. Their keep cost is identical regardless of
  the concrete type.
- **Copy types** — `bool`, `u8` … `u64` — are passed as a `u64`. Their keep cost
  is identical regardless of the concrete type.

So the baseline never needs to construct a value of the benchmark's exact result
type. It uses one of two helpers (also from the `benchmarking` library) matching
the result's *category*:

```sway
#[inline(always)]
pub fn keep_ref_type() { keep::<u256>(0u256); }   // for b256, String, structs, arrays, tuples, ...

#[inline(always)]
pub fn keep_copy_type() { keep::<u64>(0u64); }     // for bool, u8 ..= u64
```

To keep the pairing obvious, annotate each `keep_*_type()` call in a baseline
with a comment naming the benchmark value it stands in for:

```sway
#[test]
fn baseline__src16_domain__domain_hash() {
    let _ = fixture_create_src16_domain();
    keep_ref_type(); // hash
}

#[test]
fn bench__src16_domain__domain_hash() {
    let domain = fixture_create_src16_domain();

    let hash = domain.domain_hash();
    keep(hash);
}
```

Here `domain_hash` returns a `b256` (a reference type), so the baseline uses
`keep_ref_type()` annotated `// hash`.

## Worked example

Each benchmark/baseline pair differs only by the operation under measurement;
everything else (fixtures, keep) is identical, so it cancels:

```sway
#[test]
fn baseline__eip712_domain__new() {
    let _ = fixture_create_eip712_domain_args();
    keep_ref_type(); // domain
}

#[test]
fn bench__eip712_domain__new() {
    let (name, version, chain_id, verifying_contract) = fixture_create_eip712_domain_args();

    let domain = EIP712Domain::new(name, version, chain_id, verifying_contract);
    keep(domain);
}
```

`EIP712Domain::new` returns a struct (a reference type), so the baseline keeps a
`keep_ref_type()` placeholder. The cost of `new` is
`gas(bench__eip712_domain__new) - gas(baseline__eip712_domain__new)`.

## Length-dependent benchmarks

When an operation's cost depends on the size of its input (e.g. encoding a
dynamic array), a single net cost is only valid for one size. Instead, bench the
operation at **two lengths** and report the input length as the final name
segment (`__len_<n>`):

```sway
fn bench__data_encoder__dynamic_u8_array__len_1() { /* encode a 1-element Vec  */ }
fn bench__data_encoder__dynamic_u8_array__len_8() { /* encode an 8-element Vec */ }
```

Each length has its own baseline that builds a `Vec` of that length, so each
`net(len)` already excludes the `Vec`-building cost. From the two nets we recover
both the per-element cost and the fixed overhead:

```
per_element    = (net(8) - net(1)) / (8 - 1)
fixed_overhead =  net(1) - per_element
```

To make the per-length cost cancel exactly, the array fixture is **parameterized
by length** (a single `#[inline(never)]` function called with `1` and `8`),
rather than a separate fixture per length:

```sway
#[inline(never)]
fn fixture_create_vec_u8(len: u64) -> Vec<u8> {
    let mut v = Vec::new();
    let mut i = 0;
    while i < len {
        v.push(0x42u8);
        i += 1;
    }
    v
}
```
