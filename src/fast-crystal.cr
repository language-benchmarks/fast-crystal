require "option_parser"
require "./benchmarks"
require "./report"
# Needed for LLVM.default_target_triple
require "llvm"

module FastCrystal
  extend self

  def cli
    benchmarks = Hash(String, String).new
    run_all_benchmarks = false

    io = STDOUT
    # Hash of benchmarks modules with their benchmarks
    report_destination = Path["./reports", Time.utc.to_s("%Y-%m-%dT%H:%M:%S")]

    OptionParser.parse! do |parser|
      parser.banner = <<-USAGE
      Usage: #{PROGRAM_NAME} [benchmarks]
      
      Run Crystal benchmarks
      
      Benchmarks are comma-separated, 'all' to run all of them.

      USAGE

      parser.on "-a", "--all", "Run all benchmarks" do
        run_all_benchmarks = true
      end

      parser.on "-o", "--output DESTINATION", "JSON report file destination (default: #{report_destination})" do |destination|
        report_destination = Path.new destination
      end

      parser.on "-h", "--help", "Show this help" { puts parser; exit }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        abort parser
      end

      parser.unknown_args do
        if !ARGV.empty?
          STDERR.puts "ERROR: `#{ARGV.first}` is not a valid option."
          abort parser
        end
      end

      if ARGV.empty?
        puts parser
        exit
      end

      Report.options benchmarks, parser
    end

    # Build JSON report file
    Dir.mkdir report_destination.dirname if !File.exists? report_destination.dirname
    File.touch report_destination.to_s if !File.exists? report_destination.to_s
    File.open report_destination.to_s, "w" do |io|
      Report.new(STDOUT, run_all_benchmarks, benchmarks).to_pretty_json io
    end
  end
end

FastCrystal.cli
