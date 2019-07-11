require "json"

class Benchmark::IPS::Entry
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  @action : ->

  @[JSON::Field(ignore: true)]
  @ran : Bool
end

struct FastCrystal::Report
  include JSON::Serializable

  @system_information : SystemInformation = SystemInformation.new
  @benchmarks : Hash(String, Hash(String, Array(Benchmark::IPS::Entry)))

  @[JSON::Field(ignore: true)]
  @io : IO

  def initialize(@io : IO, run_all_benchmarks : Bool, benchmarks : Hash(String, String))
    @benchmarks = run_benchmarks run_all_benchmarks, benchmarks
  end

  macro finished
    {% benchmarks = Benchmarks.constants.map &.split("(").first.gsub /Benchmark/, "" %}

    def self.options(benchmarks : Hash(String, String), parser : OptionParser) : Nil
      {% for const in benchmarks %}
      parser.on "--{{const.downcase.id}} BENCHMARKS", "Run {{const.id}} benchmarks" do |benchmark|
        benchmarks[{{const}}] = benchmark
      end
      {% end %}
    end
    
    private def run_benchmarks(run_all_benchmarks : Bool, benchmarks : Hash(String, String))
      benchmarks_report = Hash(String, Hash(String, Array(Benchmark::IPS::Entry))).new
      {% for const in benchmarks %}
      if run_all_benchmarks
        @io.puts {{const}}
        benchmarks_report[{{const}}] = Hash(String, Array(Benchmark::IPS::Entry)).new
        Benchmarks::{{const.id}}Benchmark.run "all" do |name, items|
          @io.puts name
          benchmarks_report[{{const}}][name] = items
        end
      elsif benchmark_names = benchmarks[{{const}}]?
        @io.puts {{const}}
        benchmarks_report[{{const}}] = Hash(String, Array(Benchmark::IPS::Entry)).new
        benchmark_names.split ',' do |benchmark_name|
          Benchmarks::{{const.id}}Benchmark.run benchmark_name do |name, items|
            @io.puts name
            benchmarks_report[{{const}}][name] = items
          end
        end
      end
      {% end %}
      benchmarks_report
    end
  end

  struct SystemInformation
    include JSON::Serializable

    def initialize
    end

    @crystal_build_commit = Crystal::BUILD_COMMIT
    @crystal_build_date = Crystal::BUILD_DATE
    @crystal_version = Crystal::VERSION

    # Kernel name, release and version
    @kernel_name : String = `uname -s`.chomp
    @kernel_release : String = `uname -r`.chomp
    @kernel_version : String = `uname -v`.chomp

    @cpu_model : String = begin
      {% if flag?(:linux) %}\
      cpu_model = nil
      File.each_line "/proc/cpuinfo" do |line|
        if line.starts_with? "model name"
          cpu_model = line.partition(": ").last
          break
        end
      end
      cpu_model.as String
      {% elsif flag?(:darwin) %}\
      `sysctl -n machdep.cpu.brand_string`.chomp
      {% end %}
    end
    @llvm_version = Crystal::LLVM_VERSION
    @llvm_default_target = LLVM.default_target_triple
  end
end
