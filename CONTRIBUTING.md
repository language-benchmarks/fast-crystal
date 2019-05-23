# Contributing to fast-crystal

- Create a method describing the methods compared (e.g. `sort_vs_sort_by`), in which a `Benchmark.ips` will be present.
- Add this method to the proper module. For example if methods compared are from `Array`, put the benchmark to `FastCrystal::Benchmarks::ArrayBenchmark`.
- Check if changing the report orders (`x.report`) modify which expression is fastest/slower. If so, they are likely similar and doesn't need to be benchmarked.

