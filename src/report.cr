require "json"

class Benchmark::IPS::Entry
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  @action : -> = ->{}

  @[JSON::Field(ignore: true)]
  @ran : Bool

  def each_ivar(&block)
    yield "mean", human_mean
    yield "iteration time", human_iteration_time
    yield "relative stddev", relative_stddev.humanize(precision: 4, significant: false)
    yield "bytes per op", bytes_per_op.humanize(base: 1024)
  end
end

struct FastCrystal::Report
  include JSON::Serializable

  @system_information : SystemInformation = FastCrystal::Report::SystemInformation.new
  @benchmarks : Hash(String, Hash(String, Array(Benchmark::IPS::Entry)))

  @[JSON::Field(ignore: true)]
  @io : IO = STDOUT

  def initialize(run_all_benchmarks : Bool, benchmarks : Hash(String, String), @io : IO = STDOUT)
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

  def to_markdown(io : IO = STDOUT)
    io << "# System Information"

    build_markdown_table io, @system_information

    io << "# Benchmark results\n"

    @benchmarks.each do |class_name, methods|
      io << "## " << class_name << '\n'
      methods.each do |method, reports|
        io << "### " << method << '\n'
        reports.each do |report|
          io << "#### " << report.label
          if report.slower == 1.0
            io << " (fastest)"
          else
            io << " (slower: " << report.slower.humanize(precision: 3, significant: false) << ')'
          end
          build_markdown_table io, report
        end
      end
    end
  end

  private def build_markdown_table(io : IO, object)
    io << <<-E
             

   | | |
   |-|-|

   E
    object.each_ivar do |name, value|
      io << '|' << name << '|' << value << "|\n"
    end
    io << <<-E
    | | |


    E
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

    def each_ivar(&block)
      {% for ivar in @type.instance_vars %}
      yield {{ivar.stringify.tr "_", " "}}, @{{ivar}}
      {% end %}
    end
  end
end
