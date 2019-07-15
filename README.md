# Fast Crystal

Benchmarks of common idioms in Crystal, to help write more performant code.

Inspired by [fast-ruby](https://github.com/JuanitoFatas/fast-ruby).

Result of the merge of [@icyleaf](https://github.com/icyleaf)'s [fast-crystal](https://github.com/icyleaf/fast-crystal) and [@konung](https://github.com/icyleaf)'s [fast-crystal](https://github.com/konung/fast-crystal)

## Generate a report

Before continuing, the project as to be compiled

`crystal build --release src/fast-crystal.cr`

To publish your reports and see others, go to the [Language Benchmarks Reports](https://github.com/language-benchmarks/reports) repository.

### JSON

Running a benchmark results to a JSON report.

Run all benchmarks

`./fast-crystal --all`

Specific benchmarks can also be selected

`./fast-crystal --array=bsearch_vs_find,first_vs_index --hash=all`

The reports are in the `./reports` directory by default.

### Markdown

After having run the benchmarks, which result of a JSON file, a markown report can be generated from it to the `STDOUT`:

`./fast-crystal -m -f reports/2019-01-20T18:00:00.json`

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)


## License

Copyright (c) 2019 Language Benchmark members - ISC License
