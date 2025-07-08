module TrimmableCLIParser

import Moshi.Data: @data
import Moshi.Match: @match

export parse_args, ArgSpec, OptionValWithDefault

@data OptionValWithDefault begin
    IntVal(Int)
    FloatVal(Float64)
    StringVal(String)
end
getdefault(val::OptionValWithDefault.Type) = @match val begin
    OptionValWithDefault.IntVal(x) => x
    OptionValWithDefault.FloatVal(x) => x
    OptionValWithDefault.StringVal(s) => s
end
gettype(val::OptionValWithDefault.Type) = typeof(getdefault(val))

"One `ArgSpec` defines a single flag."
@data ArgSpec begin
    struct Flag
        long::String
        short::String
        help::String
    end
    struct Option
        long::String
        short::String
        help::String
        optionval::OptionValWithDefault.Type
    end
end

# don't parse strings
maybeparse(T::Type{<:Number}, x) = parse(T, x)
maybeparse(T::Type{<:AbstractString}, x) = string(x)

"Search through the vector of `args` for a single `spec` and process it."
function parse_one_spec(spec::ArgSpec.Type, args::Vector{String})
    idx = findfirst(a -> a == spec.long || a == spec.short, args)
    return @match spec begin
        ArgSpec.Flag(_, _, _) => !isnothing(idx)
        ArgSpec.Option(_, _, _, optionval) => begin
            isnothing(idx) && return getdefault(optionval)
            (idx + 1) > length(args) && error("Argument $(spec.long) requires a value.")
            val_str = args[idx + 1]
            return maybeparse(gettype(optionval), val_str)
        end
    end
end

"""
    parse_args(schema, argc, argv)

C-style interface, taking in `argc::Cint` and `argv::Ptr{Ptr{Cchar}}`.
Will crash if `argc > length(args)`.
"""
function parse_args(schema::NTuple{N, ArgSpec.Type} where {N},
                    argc::Cint, argv::Ptr{Ptr{Cchar}})
    args = [unsafe_string(unsafe_load(argv, i)) for i in 1:argc]
    return parse_args(schema, args)
end

"""
    print_help(schema)

Print help information for all arguments in the schema.
"""
function print_help(schema::NTuple{N, ArgSpec.Type} where {N})
    println(Core.stdout, "Options:")
    for spec in schema
        @match spec begin
            ArgSpec.Flag(long, short, help) => begin
                println(Core.stdout, "  $short, $long")
                println(Core.stdout, "      $help")
            end
            ArgSpec.Option(long, short, help, optionval) => begin
                default_val = getdefault(optionval)
                println(Core.stdout, "  $short, $long")
                println(Core.stdout, "      $help (default: $default_val)")
            end
        end
    end
end

"""
    parse_args(schema, args)

Main entry point. Statically infers key names and value types, and returns a named tuple.
If the result contains a `help` field set to `true`, prints help and exits.
"""
function parse_args(schema::NTuple{N, ArgSpec.Type} where {N},
                    args::Vector{<:AbstractString} = ARGS)
    keys = map(s -> Symbol(replace(s.long, "--" => "")), schema)
    values = map(s -> parse_one_spec(s, args), schema)
    result = NamedTuple{keys}(values)
    
    # Check if help was requested
    if haskey(result, :help) && result.help
        print_help(schema)
        exit(0)
    end
    
    return result
end

end

# Local Variables:
# julia-snail-extra-args: "--project=.. -e 'cd(\"..\"); using Revise, TrimmableCLIParser'"
# End:
