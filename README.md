# TrimmableCLIParser.jl

This is an attempt to create a very simple CLI parser in Julia that's fully type inferrable, so that we can use it for Julia 1.12 trimming.
It is built on Algebraic Data Types using Moshi.jl.

### Example Usage:

``` julia
using TrimmableCLIParser

Base.@ccallable function main(argc::Cint, argv::Ptr{Ptr{Cchar}})::Cint
    cli_schema = (
        ArgSpec.Flag("--verbose", "-v", "Enable verbose logging"),
        ArgSpec.Option("--port", "-p", "The port to listen on", OptionValWithDefault.IntVal(8080)),
        ArgSpec.Option("--rate", "-r", "The processing rate", OptionValWithDefault.FloatVal(1.5)),
        ArgSpec.Option("--name", "-r", "Experiment name", OptionValWithDefault.StringVal("exp1")),
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
