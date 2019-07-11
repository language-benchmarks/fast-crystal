require "benchmark"

module FastCrystal::BaseBenchmark
  macro included
  extend self

  def run(benchmark : String, &block : String, Array(Benchmark::IPS::Entry) ->)
    \{% begin %}
    \{% all_methods = [] of String %}
    case benchmark
    \{% for method in @type.methods %}
    \{% if method.name.stringify != "run" %}
    when \{{method.name.stringify}}
      yield \{{method.name.stringify}}, \{{method.name}}.items
    \{% all_methods << method.name.stringify %}
    \{% end %}
    \{% end %}
    when "all"
      \{% for method in all_methods %}
      yield \{{method}}, \{{method.id}}.items
      \{% end %}
    else
      raise "not supported benchmark: " + benchmark
    end
    \{% end %}
  end
  end
end
