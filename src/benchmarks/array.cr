module FastCrystal::Benchmarks::ArrayBenchmark
  include BaseBenchmark

  def bsearch_vs_find
    array = (0..99_999).to_a

    Benchmark.ips do |x|
      x.report "Array#find" { array.find &.> 77_777 }
      x.report "Array#bsearch" { array.bsearch &.> 77_777 }
    end
  end

  def insert_vs_unshift
    array0 = Array(Int32).new
    array1 = array0.dup

    Benchmark.ips do |x|
      x.report "Array#unshift" { 99_999.times { |i| array0.unshift i } }
      x.report "Array#insert" { 99_999.times { |i| array1.insert 0, i } }
    end
  end

  def sort_vs_sort_by
    array0 = Array.new 999 do
      rand 999_999_999
    end
    array1 = array0.dup

    Benchmark.ips do |x|
      x.report "Enumerable#sort_by" { array0.sort_by &.trailing_zeros_count }
      x.report "Enumerable#sort" { array1.sort { |a, b| a.trailing_zeros_count <=> b.trailing_zeros_count } }
    end
  end

  def reverse_each_vs_reverse_dot_each
    array = (0..99_999).to_a

    Benchmark.ips do |x|
      x.report "Array#reverse_each" { array.reverse_each &.to_s }
      x.report "Array#reverse.each" { array.reverse.each &.to_s }
    end
  end
end
