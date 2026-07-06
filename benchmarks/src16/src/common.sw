library;

/// The global fallback baseline (see the baseline-resolution rules in the
/// benchmarks `README.md`). Measures the bare overhead common to every benchmark
/// project. `forc test` does not run tests from dependency libraries, so this
/// fallback must live in each benchmark project (it cannot be shared via the
/// `benchmarking` library).
#[test]
fn baseline() {}
