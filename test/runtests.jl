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
        report1 = @report_opt TrimmableCLIParser.parse_args(TEST_CLI_SCHEMA, TEST_ARGS)
        @test isempty(report1.reports) "JET found issues in parse_args with Vector{String}: $(report1.reports)"
        
        # Test with default ARGS
        println("Testing parse_args with default ARGS...")
        report2 = @report_opt TrimmableCLIParser.parse_args(TEST_CLI_SCHEMA)
        @test isempty(report2.reports) "JET found issues in parse_args with default ARGS: $(report2.reports)"
        
        if isempty(report1.reports) && isempty(report2.reports)
            println("✓ All JET.jl checks passed!")
        end
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
