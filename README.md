# Advent Of Code 2022

This is my advent of code repo containing Advent of code challenges written in
Elixir.

## Installation

Make sure you have Erlang and Elixir installed on your machine, either through
Homebrew or apt-get or alternatively through [ASDF](https://asdf-vm.com/)

Once installed execute the following command on a terminal in this repository:

```
mix deps.get
```

## Checking out the challenges

All challenges are written as Uni tests in the test directory. You can check the
challenges out in the test directory or better yet; you can execute them!

The main test command will run all the tests in alphabetical order (so per day
and per challenge) in a trace-view mode.

Most tests will execute an assert on demo-data first and then put the result of
the real test in the console output.

```
mix test
```

You can execute individual days (or even challenges) by executing any of the
below:

```
mix test test/01/day_1_test.exs

mix test test/01/day_1_test.exs:66
```
