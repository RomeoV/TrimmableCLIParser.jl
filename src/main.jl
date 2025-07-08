using TrimmableCLIParser

const EXAMPLE_CLI_SCHEMA = (
    ArgSpec.Flag("--verbose", "-v", "Enable verbose logging"),
    ArgSpec.IntOption("--port", "-p", "The port to listen on", Int, 8080),
    ArgSpec.FloatOption("--rate", "-r", "The processing rate", Float64, 1.5),
)
const EXAMPLE_ARGS = ["--verbose", "--port", "1234"]

function main(args = ARGS)
    cli_schema = EXAMPLE_CLI_SCHEMA
    config = parse_args(cli_schema, args)

    if config.verbose
        println("Verbose mode is on!")
    end
    println("Processing with port: ", config.port, " and rate: ", config.rate)
    println(Core.stdout, config)
    return nothing # Return Nothing for a clean JET report
end

Base.@ccallable function main(argc::Cint, argv::Ptr{Ptr{Cchar}})::Cint
    cli_schema = EXAMPLE_CLI_SCHEMA
    config = parse_args(cli_schema, argc, argv)

    if config.verbose
        println(Core.stdout, "Verbose mode is on!")
    end
    println(Core.stdout, "Processing with port $(config.port)")
    println(Core.stdout, "and rate $(config.rate)")
    return 0
end
Base.Experimental.entrypoint(main, (Cint, Ptr{Ptr{Cchar}}))

# --- JET.jl Analysis example ---
# @report_opt TrimmableCLIParser.parse_args(TrimmableCLIParser.EXAMPLE_CLI_SCHEMA, TrimmableCLIParser.EXAMPLE_ARGS)

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
