module FastCrystal::Benchmarks::HashBenchmark
  include BaseBenchmark

  def each_key_vs_keys_each
    hash = Hash(String, String).new
    str = "a"
    9.times do
      hash[str] = str
      str += str
    end

    Benchmark.ips do |x|
      x.report "Hash#each_key" { hash.each_key &.to_s }
      x.report "Hash#keys.each" { hash.keys.each &.to_s }
    end
  end

  def has_key_vs_brackets
    hash = Hash(String, String).new
    str = "a"
    9.times do
      hash[str] = str
      str += str
    end

    Benchmark.ips do |x|
      x.report "Hash#has_key?" { hash.has_key? "aaaaa" }
      x.report "Hash#[]?" { hash["aaaaa"]? }
    end
  end
end
