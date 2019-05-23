require "option_parser"
require "./benchmarks"

module FastCrystal
  extend self
  @@benchmarks = Hash(String, String).new
  @@run_all_benchmarks = false

  def cli
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
        @@run_all_benchmarks = true
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

      benchmark_options parser
    end

    # Prepare JSON report file
    Dir.mkdir report_destination.dirname if !File.exists? report_destination.dirname
    File.touch report_destination.to_s if !File.exists? report_destination.to_s
    file_io = File.new report_destination.to_s, "w"
    json = JSON::Builder.new file_io
    json.indent = "  "

    json.document do
      json.object do
        json.field "Crystal Version", `crystal -v`
        json.flush
        run_benchmarks json, io
      end
    end

    json.flush
    file_io.close
  end

  macro finished
  {% benchmarks = Benchmarks.constants.map &.split("(").first.gsub /Benchmark/, "" %}

  def benchmark_options(parser : OptionParser) : Nil
    {% for const in benchmarks %}
    parser.on "--{{const.downcase.id}} BENCHMARKS", "Run {{const.id}} benchmarks" do |benchmark|
      @@benchmarks[{{const}}] = benchmark
    end
    {% end %}
  end
  
  def run_benchmarks(json : JSON::Builder, io : IO) : Nil
    {% for const in benchmarks %}
    if @@run_all_benchmarks || (benchmark = @@benchmarks[{{const}}]?)
      io.puts {{const}}
      json.field {{const}} do
        json.object do
          if @@run_all_benchmarks
            Benchmarks::{{const.id}}Benchmark.run "all", json, io
          elsif benchmark
            benchmark.split ',' do |benchmark|
              Benchmarks::{{const.id}}Benchmark.run benchmark, json, io
            end
          end
        end
      end
    end
    {% end %}
  end
  end
end

FastCrystal.cli
