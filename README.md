# TrimmableCLIParser.jl

This is an attempt to create a very simple CLI parser in Julia that's fully type inferrable, so that we can use it for Julia 1.12 trimming.
It is built on Algebraic Data Types using Moshi.jl.

*Currently, the final type inference for the output type of `parse_args` is still somewhat broken...*

Example Usage:

``` julia
using TrimmableCLIParser

Base.@ccallable function main(argc::Cint, argv::Ptr{Ptr{Cchar}})::Cint
    cli_schema = (
        ArgSpec.Flag("--verbose", "-v", "Enable verbose logging"),
        ArgSpec.IntOption("--port", "-p", "The port to listen on", Int, 8080),
        ArgSpec.FloatOption("--rate", "-r", "The processing rate", Float64, 1.5),
    )
    config = parse_args(cli_schema, argc, argv)

    # use
    config.verbose, config.port, config.rate

    return 0
end
```
