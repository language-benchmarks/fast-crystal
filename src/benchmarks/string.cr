module FastCrystal::Benchmarks::StringBenchmark
  include BaseBenchmark

  def concatenation_vs_interpolation_6_times
    str = "abc"

    Benchmark.ips do |x|
      x.report "6 * String#+" { str + str + str + str + str + str }
      x.report "6 * Interpolation" { "#{str}#{str}#{str}#{str}#{str}#{str}" }
    end
  end

  def concatenation_vs_interpolation_2_times
    str = "abc"

    Benchmark.ips do |x|
      x.report "2 * String#+" { str + str }
      x.report "2 * Interpolation" { "#{str}#{str}" }
    end
  end

  def gsub_vs_sub
    str = "abcdefghijklmnopqrstuvwxyz"

    Benchmark.ips do |x|
      x.report "String#gsub" { str.gsub "cd", "X" }
      x.report "String#sub" { str.sub "cd", "X" }
    end
  end

  def each_char_vs_chars_each
    str = "abcdefghijklmnopqrstuvwxyz"

    Benchmark.ips do |x|
      x.report "String#chars.each" { str.chars.each &.to_s }
      x.report "String#each_char" { str.each_char &.to_s }
    end
  end
end
