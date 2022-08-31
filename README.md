# Maze Runner 🏃

A test runner for validating requests

## How it works

The test harness launches a mock API which awaits requests from sample
applications. Using the runner, each scenario is executed and the requests are
validated to have to correct fields and values. Uses Gherkin and Cucumber under
the hood to draft semantic tests.

## Documentation

[Documentation for Cucumber steps in the latest release can be found here.](https://bugsnag.github.io/maze-runner/)

[The Maze Runner handbook markdown docs can be found here](./DOCS.md)

### Running the tests

Maze Runner uses test-unit and minunit to bootstrap itself and run the
sample app suites in the test fixtures. Run `bundle exec rake` to run the suite.

