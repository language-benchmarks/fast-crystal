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
    markdown_report = false

    io = STDOUT
    # Hash of benchmarks modules with their benchmarks
    report_file = Path["./reports", Time.utc.to_s("%Y-%m-%dT%H:%M:%S") + ".json"]

    OptionParser.parse! do |parser|
      parser.banner = <<-USAGE
      Usage: #{PROGRAM_NAME} [benchmarks]
      
      Run Crystal benchmarks
      
      Benchmarks are comma-separated, 'all' to run all of them.

      USAGE

      parser.on "-a", "--all", "Run all benchmarks" do
        run_all_benchmarks = true
      end

      parser.on "-m", "--markdown", "Generate a markdown report from a JSON file" do
        markdown_report = true
      end

      parser.on "-f", "--file DESTINATION", "JSON report file (default: #{report_file})" do |destination|
        report_file = Path.new destination
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

    if markdown_report
      File.open report_file.to_s, "r" do |io|
        Report.from_json(io).to_markdown
      end
    else
      # Build JSON report file
      Dir.mkdir report_file.dirname if !File.exists? report_file.dirname
      File.touch report_file.to_s if !File.exists? report_file.to_s
      File.open report_file.to_s, "w" do |io|
        Report.new(run_all_benchmarks, benchmarks).to_pretty_json io
      end
    end
  end
end

FastCrystal.cli
