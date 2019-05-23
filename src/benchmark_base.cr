require "benchmark"
require "json"

class Benchmark::IPS::Entry
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  @action : ->

  @[JSON::Field(ignore: true)]
  @ran : Bool
end

module FastCrystal::BaseBenchmark
  macro included
  extend self

  def run(benchmark : String, json : JSON::Builder, io : IO) : Nil
    \{% begin %}
    \{% all_methods = [] of String %}
    case benchmark
    \{% for method in @type.methods %}
    \{% if method.name.stringify != "run" %}
    when \{{method.name.stringify}}
      report(\{{method.name.stringify}}, json, io) { \{{method.name}} }
    \{% all_methods << method.name.stringify %}
    \{% end %}
    \{% end %}
    when "all"
      \{% for method in all_methods %}
      report(\{{method}}, json, io) { \{{method.id}} }
      \{% end %}
    else
      raise "not supported benchmark: " + benchmark
    end
    \{% end %}
  end
  end

  def report(name : String, json : JSON::Builder, io : IO, &block) : Nil
    io.puts name
    json.field name do
      yield.items.to_json json
    end
    json.flush
  end
end
