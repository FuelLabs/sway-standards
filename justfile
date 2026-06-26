# lists the available recipes
default:
    @just --list --unsorted

alias bs := build-standards
# builds the standards; additional arguments are forwarded to `forc build`, e.g.: `just bs --release`
build-standards *args:
    ./scripts/build-standards.sh {{ args }}

alias be := build-examples
# builds the examples; additional arguments are forwarded to `forc build`, e.g.: `just be --release`
build-examples *args:
    ./scripts/build-examples.sh {{ args }}

alias ba := build-all
# builds the standards and the examples; e.g.: `just ba --release`
build-all *args: (build-standards args) (build-examples args)

alias b := bench
# runs a benchmark project and prints the results; e.g.: `just b -p benchmarks/src16 -f ascii`
bench *args:
    ./scripts/forc-bench.sh {{ args }}
