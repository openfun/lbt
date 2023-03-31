# LBT, the LRS Benchmarking Tool

## Description

LBT is a tool and a playground to benchmark performances of open-source
[Learning Record Stores](https://xapi.com/learning-record-store/). This project
aims at helping universities, institutes, schools or edtechs to pick the LRS
that best fit with their needs and constraints.

⚠️ This project is still in early development. ⚠️

## Quick start guide (for developers)

Once you've cloned the project, start an LRS using:

```
$ make run-lrs-ralph
```

And then run a benchmark:

```
$ bin/bench \
      http://AAA:BBB@ralph:8090/xAPI \
      /app/locust/post.py \
      30 \
      1 \
      1
```

Usage of the `bin/bench` script is:

```
usage: bin/bench LRS_ROOT_URL PROTOCOL [DURATION] [CONCURRENT_USERS] [STATEMENTS_PER_REQUEST]
```

You will find your results in the latest runs directory:

```
$ ls runs | tail -n 1
```

You should see a bunch of CSV files created by `locust` and a `parameters.txt`
file containing the input parameters used for this run:

```
runs/2023-03-31T17:04:04,102856292-04:00
├── parameters.txt
├── run_exceptions.csv
├── run_failures.csv
├── run_stats.csv
└── run_stats_history.csv

0 directories, 5 files
```

## Contributing

This project is intended to be community-driven, so please, do not hesitate to
get in touch if you have any question related to our implementation or design
decisions.

We try to raise our code quality standards and expect contributors to follow
the recommandations from our
[handbook](https://handbook.openfun.fr).

## License

This work is released under the MIT license (see [LICENSE](./LICENSE)).

