library;

/// Forces a value — and the computation that produced it — to be materialized,
/// so the optimizer cannot eliminate the code under measurement. `keep` is
/// `#[inline(never)]`, so its only cost is passing the argument.
#[inline(never)]
pub fn keep<T>(_t: T) {}

/// Stands in, in a baseline, for a benchmark's `keep` of a reference type
/// (`b256`, `u256`, `String`, arrays, tuples, and any struct — all passed as a
/// pointer). Its keep cost is identical regardless of the concrete type.
#[inline(always)]
pub fn keep_ref_type() {
    keep::<u256>(0u256);
}

/// Stands in, in a baseline, for a benchmark's `keep` of a copy type
/// (`bool`, `u8` ..= `u64` — all passed as a `u64`). Its keep cost is identical
/// regardless of the concrete type.
#[inline(always)]
pub fn keep_copy_type() {
    keep::<u64>(0u64);
}
