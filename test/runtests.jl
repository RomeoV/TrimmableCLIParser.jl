using Test
using JET
using TrimmableCLIParser

# Test schema similar to main.jl
const TEST_CLI_SCHEMA = (
    ArgSpec.Flag("--verbose", "-v", "Enable verbose logging"),
    ArgSpec.Option("--port", "-p", "The port to listen on", OptionValWithDefault.IntVal(8080)),
    ArgSpec.Option("--rate", "-r", "The processing rate", OptionValWithDefault.FloatVal(1.5)),
    ArgSpec.Option("--name", "-n", "Experiment name", OptionValWithDefault.StringVal("exp1")),
    ArgSpec.Flag("--help", "-h", "Print help"),
)

const TEST_ARGS = ["--verbose", "--port", "1234", "--rate", "2.0"]

@testset "TrimmableCLIParser Tests" begin
    @testset "JET.jl Analysis" begin
        println("Running JET.jl analysis...")
        
        # Test the main parse_args function with Vector{String} args
        println("Testing parse_args with Vector{String}...")
        @test_opt TrimmableCLIParser.parse_args(TEST_CLI_SCHEMA, TEST_ARGS)
        
        # Test with default ARGS
        println("Testing parse_args with default ARGS...")
        argc = Cint(length(TEST_ARGS))
        argv = pointer([
            pointer(Base.unsafe_convert(Cstring, arg))
            for arg in TEST_ARGS])
        @test_opt TrimmableCLIParser.parse_args(TEST_CLI_SCHEMA, argc, argv)
        
        println("✓ All JET.jl checks passed!")
    end
    
    @testset "Basic Functionality" begin
        # Test basic parsing
        result = TrimmableCLIParser.parse_args(TEST_CLI_SCHEMA, TEST_ARGS)
        @test result.verbose == true
        @test result.port == 1234
        @test result.rate == 2.0
        @test result.name == "exp1"  # default value
        @test result.help == false   # default value
    end
end
