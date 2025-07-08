using TrimmableCLIParser

const EXAMPLE_CLI_SCHEMA = (
    ArgSpec.Flag("--verbose", "-v", "Enable verbose logging"),
    ArgSpec.Option("--port", "-p", "The port to listen on", OptionValWithDefault.IntVal(8080)),
    ArgSpec.Option("--rate", "-r", "The processing rate", OptionValWithDefault.FloatVal(1.5)),
    ArgSpec.Option("--name", "-n", "Experiment name", OptionValWithDefault.StringVal("exp1")),
    ArgSpec.Flag("--help", "-h", "Print help"),
)
const EXAMPLE_ARGS = ["--verbose", "--port", "1234"]

function main(args = ARGS)
    cli_schema = EXAMPLE_CLI_SCHEMA
    config = parse_args(cli_schema, args)
    print_config(config)
    return nothing # Return Nothing for a clean JET report
end

Base.@ccallable function main(argc::Cint, argv::Ptr{Ptr{Cchar}})::Cint
    cli_schema = EXAMPLE_CLI_SCHEMA
    config = parse_args(cli_schema, argc, argv)
    print_config(config)
    return 0
end
Base.Experimental.entrypoint(main, (Cint, Ptr{Ptr{Cchar}}))

@inline function print_config(config)
    if config.verbose
        println(Core.stdout, "Verbose mode is on!")
    end
    println(Core.stdout, "[Experiment $(config.name)]")
    print(Core.stdout, "Processing with port $(config.port) ")
    println(Core.stdout, "and rate $(config.rate).")
    return nothing
end

# --- JET.jl Analysis example ---
# @report_opt TrimmableCLIParser.parse_args(TrimmableCLIParser.EXAMPLE_CLI_SCHEMA, TrimmableCLIParser.EXAMPLE_ARGS)
# or
# @report_opt main()

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
