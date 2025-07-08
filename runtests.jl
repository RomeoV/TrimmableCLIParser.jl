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

function run_tests()
    println("Running JET.jl analysis...")
    
    # Test the main parse_args function with Vector{String} args
    println("Testing parse_args with Vector{String}...")
    report1 = @report_opt TrimmableCLIParser.parse_args(TEST_CLI_SCHEMA, TEST_ARGS)
    
    # Test the C-style interface
    println("Testing parse_args with C-style interface...")
    # Create a mock argc/argv for testing
    argc = Cint(length(TEST_ARGS))
    argv_strings = TEST_ARGS
    # We can't easily create a real Ptr{Ptr{Cchar}} in pure Julia for testing,
    # so we'll just test the Vector{String} version which is the core logic
    
    # Test with default ARGS
    println("Testing parse_args with default ARGS...")
    report2 = @report_opt TrimmableCLIParser.parse_args(TEST_CLI_SCHEMA)
    
    # Check if there were any issues
    if isempty(report1.reports) && isempty(report2.reports)
        println("✓ All JET.jl checks passed!")
        return true
    else
        println("✗ JET.jl found potential issues:")
        if !isempty(report1.reports)
            println("Issues in parse_args with Vector{String}:")
            for report in report1.reports
                println("  - ", report)
            end
        end
        if !isempty(report2.reports)
            println("Issues in parse_args with default ARGS:")
            for report in report2.reports
                println("  - ", report)
            end
        end
        return false
    end
end

# Run the tests
if abspath(PROGRAM_FILE) == @__FILE__
    success = run_tests()
    exit(success ? 0 : 1)
end
