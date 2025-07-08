# -*- julia-snail-extra-args: "--project=.. -e 'cd(\"..\"); using Revise, TrimmableCLIParser'"; -*-
module TrimmableCLIParser

import Moshi.Data: @data
import Moshi.Match: @match

@data ArgSpec begin
    struct Flag
        long::String
        short::String
        help::String
    end
    struct StringOption
        long::String
        short::String
        help::String
        type::Type{String}
        default::String
    end
    struct IntOption
        long::String
        short::String
        help::String
        type::Type{Int}
        default::Int
    end
    struct FloatOption
        long::String
        short::String
        help::String
        type::Type{Float64}
        default::Float64
    end
end

maybeparse(T::Type{<:Number}, x) = parse(T, x)
maybeparse(T::Type{<:AbstractString}, x) = string(x)

function parse_one_spec(spec::ArgSpec.Type, args::Vector{String})
    idx = findfirst(a -> a == spec.long || a == spec.short, args)
    return @match spec begin
        ArgSpec.Flag(_, _, _) => !isnothing(idx)
        (
            ArgSpec.IntOption(_, _, _, T, default)
                || ArgSpec.FloatOption(_, _, _, T, default)
                || ArgSpec.StringOption(_, _, _, T, default)
        ) => begin
            isnothing(idx) && return spec.default
            #
            if (idx + 1) > length(args)
                error("Argument $(spec.long) requires a value.")
            end
            val_str = args[idx + 1]
            return maybeparse(T, val_str)
        end
    end
end

function parse_args(schema::NTuple{N, ArgSpec.Type} where {N}, args::Vector{String} = ARGS)
    keys = map(s -> Symbol(replace(s.long, "--" => "")), schema)
    values = map(s -> parse_one_spec(s, args), schema)
    return NamedTuple{keys}(values)
end

function main(args = ARGS)
    cli_schema = (
        ArgSpec.Flag("--verbose", "-v", "Enable verbose logging"),
        ArgSpec.IntOption("--port", "-p", "The port to listen on", Int, 8080),
        ArgSpec.FloatOption("--rate", "-r", "The processing rate", Float64, 1.5),
    )
    config = parse_args(cli_schema, args)

    if config.verbose
        println("Verbose mode is on!")
    end
    println("Processing with port: ", config.port, " and rate: ", config.rate)
    return nothing # Return Nothing for a clean JET report
end

# --- JET.jl Analysis example ---
# @report_opt main(["-v", "--port", "999"])

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end

end
