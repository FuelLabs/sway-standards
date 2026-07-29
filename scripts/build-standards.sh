#!/usr/bin/env bash

# Builds all the standards located in the `./standards` folder, in parallel.
#
# Any arguments passed to this script are forwarded as-is to `forc build`, e.g.:
#
#     ./scripts/build-standards.sh --release --experimental dynamic_storage
#
# See `build.sh` for the full behavior.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/build.sh" standards standard "$@"
