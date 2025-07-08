# -*- julia-snail-extra-args: "--project=.. -e 'cd(\"..\"); using Revise, TrimmableCLIParser'"; -*-
module TrimmableCLIParser

using SumTypes

public parse_args, ArgSpec

@sum_type ArgSpec begin
    Flag(long::String, short::String, help::String)
    StringOption(long::String, short::String, help::String, type::Type{String}, default::String)
    IntOption(long::String, short::String, help::String, type::Type{Int}, default::Int)
    FloatOption(long::String, short::String, help::String, type::Type{Float64}, default::Float64)
end

maybeparse(T::Type{<:Number}, x) = parse(T, x)
maybeparse(T::Type{<:AbstractString}, x) = string(x)

function parse_one_spec(spec::ArgSpec, args::Vector{String})
    idx = findfirst(a -> a == spec.long || a == spec.short, args)
    return @cases spec begin
        Flag(_, _, _) => !isnothing(idx)
        IntOption(_, _, _, T, default) => begin
            isnothing(idx) && return default
            #
            if (idx + 1) > length(args)
                error("Argument $(spec.long) requires a value.")
            end
            val_str = args[idx + 1]
            return maybeparse(T, val_str)
        end
        FloatOption(_, _, _, T, default) => begin
            isnothing(idx) && return default
            #
            if (idx + 1) > length(args)
                error("Argument $(spec.long) requires a value.")
            end
            val_str = args[idx + 1]
            return maybeparse(T, val_str)
        end
        StringOption(_, _, _, T, default) => begin
            isnothing(idx) && return default
            #
            if (idx + 1) > length(args)
                error("Argument $(spec.long) requires a value.")
            end
            val_str = args[idx + 1]
            return maybeparse(T, val_str)
        end
    end
end


function parse_args(schema::NTuple{N, ArgSpec} where {N}, argc::Cint, argv::Ptr{Ptr{Cchar}})
    args = unsafe_string.(
        [unsafe_load(argv, i) for i in 1:argc]
    )
    parse_args(schema, args)
end

function parse_args(schema::NTuple{N, ArgSpec} where {N}, args::Vector{String} = ARGS)
    keys = map(s -> Symbol(replace(s.long, "--" => "")), schema)
    values = map(s -> parse_one_spec(s, args), schema)
    return NamedTuple{keys}(values)
end

EXAMPLE_CLI_SCHEMA = (
    Flag("--verbose", "-v", "Enable verbose logging"),
    IntOption("--port", "-p", "The port to listen on", Int, 8080),
    FloatOption("--rate", "-r", "The processing rate", Float64, 1.5),
)
EXAMPLE_ARGS = ["--verbose", "--port", "1234"]

function main(args = ARGS)
    cli_schema = (
        Flag("--verbose", "-v", "Enable verbose logging"),
        IntOption("--port", "-p", "The port to listen on", Int, 8080),
        FloatOption("--rate", "-r", "The processing rate", Float64, 1.5),
    )
    config = parse_args(cli_schema, args)

    if config.verbose
        println("Verbose mode is on!")
    end
    println("Processing with port: ", config.port, " and rate: ", config.rate)
    println(Core.stdout, config)
    return nothing # Return Nothing for a clean JET report
end

Base.@ccallable function main(argc::Cint, argv::Ptr{Ptr{Cchar}})::Cint
    cli_schema = (
        Flag("--verbose", "-v", "Enable verbose logging"),
        IntOption("--port", "-p", "The port to listen on", Int, 8080),
        FloatOption("--rate", "-r", "The processing rate", Float64, 1.5),
    )
    config = parse_args(cli_schema, argc, argv)

    if config.verbose
        println(Core.stdout, "Verbose mode is on!")
    end
    println(Core.stdout, "Processing with port: ", config.port, " and rate: ", config.rate)
    println(Core.stdout, config)
    foreach(config) do c
        println(Core.stdout, c);
        nothing
    end
    return 0
end
Base.Experimental.entrypoint(main, (Cint, Ptr{Ptr{Cchar}}))


# --- JET.jl Analysis example ---
# @report_opt TrimmableCLIParser.parse_args(TrimmableCLIParser.EXAMPLE_CLI_SCHEMA, TrimmableCLIParser.EXAMPLE_ARGS)

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end

end
