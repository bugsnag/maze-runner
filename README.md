# Maze Runner 🏃

A test runner for validating requests

## How it works

The test harness launches a mock API which awaits requests from sample
applications. Using the runner, each scenario is executed and the requests are
validated to have to correct fields and values. Uses Gherkin and Cucumber under
the hood to draft semantic tests.

## Setting up a new project

### First time setup and running locally

1. Install the `bundler` gem:

   ```shell
   gem install bundler
   ```

2. Add a Gemfile to the root of your project:

   ```ruby
   source "https://rubygems.org"
   gem "bugsnag-maze-runner", git: "https://github.com/bugsnag/maze-runner"
   ```

3. Run `bundle install` to fetch and install Maze Runner

4. Run `bundle exec maze-runner init` from the root of your project to build the
   basic structure to run test scenarios.
   * `features/fixtures`: Test fixture files, such as sample JSON payloads
   * `features/scripts`: Scripts to be run in scenarios. Any environment
     variables set in scenarios are passed to scripts. The `MOCK_API_PORT`
     variable is provided by default to configure the location of the mock
     server.
   * `features/steps`: Additional steps of the form Given/When/Then required to
     complete scenarios
   * `features/support`: Helper functions. Add any setup which should be run
     once before all of the scenarios to `features/support/env.rb`. Any setup
     which should be run before or after each scenario can go into special
     `Before` and `After` functions respectively.
   * `features/*.feature`: The plain text scenario specifications

   A sample feature is included after running `init`. Try it out with

   ```shell
   bundle exec maze-runner
   ```

## Documentation

[Full documentation can be found here.](https://bugsnag.github.io/maze-runner/)

## Contributing

If steps would be useful for different projects using maze-runner, add them to
`lib/features/steps/`. If there are useful helper functions, add them to
`lib/features/support/*.rb`.

### Running the tests

maze-runner uses test-unit and minunit to bootstrap itself and run the
sample app suites in the test fixtures. Run `bundle exec rake` to run the suite.
