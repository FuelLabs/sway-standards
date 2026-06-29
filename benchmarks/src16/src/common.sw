library;

use src16::*;

/// The global fallback baseline (see the baseline-resolution rules in the
/// benchmarks `README.md`). Measures the bare overhead common to every benchmark
/// project. `forc test` does not run tests from dependency libraries, so this
/// fallback must live in each benchmark project (it cannot be shared via the
/// `benchmarking` library).
#[test]
fn baseline() {}

/// Shared fixture for benchmarks that encode into a `Buffer` (e.g. the
/// `abi_encode` benchmarks of the domain types).
#[inline(never)]
pub fn fixture_create_buffer() -> Buffer {
    Buffer::new()
}
