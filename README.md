# TrimmableCLIParser.jl

[![CI](https://github.com/RomeoV/TrimmableCLIParser.jl/workflows/CI/badge.svg)](https://github.com/RomeoV/TrimmableCLIParser.jl/actions)
[![JET](https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a)](https://github.com/aviatesk/JET.jl)
[![Binary Size](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/RomeoV/TrimmableCLIParser.jl/gh-pages/badges/binary-size.json)](https://github.com/RomeoV/TrimmableCLIParser.jl)
[![Execution Time](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/RomeoV/TrimmableCLIParser.jl/gh-pages/badges/exec-time.json)](https://github.com/RomeoV/TrimmableCLIParser.jl)

`TrimmableCLIParser.jl` provides a simple CLI parser in Julia that is fully type inferrable so that we can use it for [trimmed binaries](https://docs.julialang.org/en/v1.12-dev/devdocs/sysimg/#Trimming) starting with Julia 1.12.
Trimmed binaries will have a much reduce memory footprint and startup speed, see for instance the size and startup speed of the example binary in this package reported in the badges above.

This library is built on Algebraic Data Types using [Moshi.jl](https://github.com/Roger-luo/Moshi.jl).

### Example Usage:

``` julia
using TrimmableCLIParser

Base.@ccallable function main(argc::Cint, argv::Ptr{Ptr{Cchar}})::Cint
    cli_schema = (
        ArgSpec.Flag("--verbose", "-v", "Enable verbose logging"),
        ArgSpec.Option("--port", "-p", "The port to listen on", OptionValWithDefault.IntVal(8080)),
        ArgSpec.Option("--rate", "-r", "The processing rate", OptionValWithDefault.FloatVal(1.5)),
        ArgSpec.Option("--name", "-n", "Experiment name", OptionValWithDefault.StringVal("exp1")),
        ArgSpec.Flag("--help", "-h", "Print help"),
    )
    config = parse_args(cli_schema, argc, argv)

    # use
    config.verbose, config.port, config.rate

    return 0
end
```

Note that the `--help` flag must be explicitly defined if printing help is desired. The code looks for this flag and triggers printing if `--help` is found.

### Example compilation
Make sure that julia 1.12 is activated for the current directory:

``` sh
juliaup override set 1.12
```

Then just run `make` to build the binary.

### Example usage
``` sh
> ./main --verbose
Verbose mode is on!
Processing with port 8080
and rate 1.5

> ./main --port 1000 --rate 0.01
Processing with port 1000
and rate 0.01

> ./main --help
Options:
  -v, --verbose
      Enable verbose logging
  -p, --port
      The port to listen on (default: 8080)
  -r, --rate
      The processing rate (default: 1.5)
  -n, --name
      Experiment name (default: exp1)
  -h, --help
      Print help
```
