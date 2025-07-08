# -*- julia-snail-extra-args: "--project=.. -e 'cd(\"..\"); using Revise, TrimmableCLIParser'"; -*-
module TrimmableCLIParser

import Moshi.Data: @data
import Moshi.Match: @match

export parse_args, ArgSpec, OptionValWithDefault

@data OptionValWithDefault begin
    # default values
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

maybeparse(T::Type{<:Number}, x) = parse(T, x)
maybeparse(T::Type{<:AbstractString}, x) = string(x)

function parse_one_spec(spec::ArgSpec.Type, args::Vector{String})
    idx = findfirst(a -> a == spec.long || a == spec.short, args)
    return @match spec begin
        ArgSpec.Flag(_, _, _) => !isnothing(idx)
        ArgSpec.Option(_, _, _, optionval) => begin
            isnothing(idx) && return getdefault(optionval)
            #
            if (idx + 1) > length(args)
                error("Argument $(spec.long) requires a value.")
            end
            val_str = args[idx + 1]
            return maybeparse(gettype(optionval), val_str)
        end
    end
end

function parse_args(schema::NTuple{N, ArgSpec.Type} where {N}, argc::Cint, argv::Ptr{Ptr{Cchar}})
    args = unsafe_string.(
        [unsafe_load(argv, i) for i in 1:argc]
    )
    return parse_args(schema, args)
end

function parse_args(schema::NTuple{N, ArgSpec.Type} where {N}, args::Vector{String} = ARGS)
    keys = map(s -> Symbol(replace(s.long, "--" => "")), schema)
    values = map(s -> parse_one_spec(s, args), schema)
    return NamedTuple{keys}(values)
end

end
