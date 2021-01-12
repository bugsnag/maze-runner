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
   gem "maze-runner", git: "https://github.com/bugsnag/maze-runner"
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

## Writing features

Features should be composed as concisely has possible, reusing existing steps as
needed. The harness provides a number of reusable step definitions for
interacting with scripts, setting environment variables, and inspecting output.
Each new feature should go into a `.feature` file in the `features` directory.

```
Feature: Sinatra support

Scenario: Sinatra unhandled exception
    When I set environment variable "BUGSNAG_API_KEY" to "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And I start a Sinatra app
    And I navigate to the route "/syntax-error"
    Then I should receive a request
    And the request is a valid for the error reporting API
    And the "Bugsnag-API-Key" header equals "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And the event "unhandled" is true
```

This example includes a mix of the included steps as well as custom ones
specific to the library being tested. `When I set an environment variable` is
provided by default while `When I start a Sinatra app` is defined in a custom
steps file in `features/steps/`, wrapping other included steps:

```ruby
When("I start a Sinatra app") do
  Runner.environment["DEMO_APP_PORT"] = DEMO_APP_PORT
  steps %Q{
    When I run the script "features/fixtures/run_sinatra_app.sh"
    And I wait for 8 seconds
  }
end

When("I navigate to the route {string}") do |route|
  steps %Q{
    When I open the URL "http://localhost:#{DEMO_APP_PORT}#{route}"
    And I wait for 1 second
  }
end
```

In addition, any helper functions or instance variables defined in
`features/support/env.rb` are available to step files. See the included
`_step.rb` files for examples. The files in `features/support` are evaluated
before scenarios are run, so this is where one-time or per-scenario
configuration should go.

 ```ruby
 # A helper function included with the harness to run commands and
 # only print output when the command fails
 run_required_commands([
   ["bundle", "install"]
 ])

 # Maybe shell out to something directly, if necessary
 `echo Peanut Butter Jelly Time`

 # Run before every scenarios
 Maze.hooks.before do
   clean_build_artifacts
 end

# Run after every scenario
Maze.hooks.after do |scenario|
  # Teardown scenario configuration here

  if scenario.failed?
    # Can be used to do specific cleanup if a scenario fails
  end
end
```

### Step definition links

- [Request assertion steps](/maze-runner/requirements/step_transformers.html#step_definition66-stepdefinition)
- [Error content steps](/maze-runner/requirements/step_transformers.html#step_definition29-stepdefinition)
- [Breadcrumb steps](/maze-runner/requirements/step_transformers.html#step_definition21-stepdefinition)
- [Session content steps](/maze-runner/requirements/step_transformers.html#step_definition57-stepdefinition)
- [Environment steps](/maze-runner/requirements/step_transformers.html#step_definition1-stepdefinition)
- [Script and docker steps](/maze-runner/requirements/step_transformers.html#step_definition7-stepdefinition)
- [BrowserStack steps](/maze-runner/requirements/step_transformers.html#step_definition25-stepdefinition)

### Step examples

#### Field path notation

Anywhere a `{field}`, `{path}`, `{key_path}`, etc is denoted, it can be replaced with dot-delimited key path to indicate 
the path from the root of an object to the intended target.

For example, to match the name of the second objects in the the key `fruits` below, use `fruits.1.name` as the keypath.

```json
{
  "fruits": [
  	{ "name": "apple" },
  	{ "name": "cherry" }
  ]
}
```

#### Using BrowserStack

BrowserStack is used to drive many of the mobile device tests written using maze-runner.  For these tests we can use a 
driver class and accompanying set of steps to interface with the BrowserStack AppAutomate server.  `Maze.driver` 
can be used to write custom steps using the API provided by the `Appium::Driver` class.

The options needed to create a connection to the Appium server should be passed in via the command line when invoking
Maze Runner.  See `bundle exec maze-runner --help` for details, but the most pertinent are:
-  `--farm=<s>` - Device farm to use: "bs" (BrowserStack) or "local"
-  `--app=<s>` - The app to be installed and run against
-  `--bs-local=<s>` - Path to the BrowserStackLocal binary
-  `--device=<s>` - BrowserStack device to use (a key of Devices.DEVICE_HASH)
-  `--username=<s>` - BrowserStack username
-  `--access-key=<s>` - BrowserStack access key

#### On matching JSON templates

For the following steps:

```
Then the payload body matches the JSON fixture in "features/fixtures/template.json"
Then the payload field "items.0.subset" matches the JSON fixture in "features/fixtures/template.json"
```

The template file can either be an exact match or specify regex matches for string fields. For example, given the 
template:
```json
{ "fruit": { "apple": { "color": "\\w+" } } }
```

The following request will match:
```json
{ "fruit": { "apple": { "color": "red" } } }
```

Though this request will not match:
```json
{ "fruit": { "apple": { "color": "red-orange" } } }
```

If "IGNORE" is specified as a value in a template, that value will be ignored in requests.

Given the following template:
```json
{ "fruit": { "apple": "IGNORE" } }
```

This request will match:
```json
{ "fruit": { "apple": "some nonsense" } }
```

## Running features

Run the entire suite using `bundle exec maze-runner`. Alternately, you can specify specific files to run:

```shell
bundle exec maze-runner features/something.feature
```

Add the `--verbose` option to print script output and a trace of what Ruby file is being run.

## Troubleshooting

### Logging

Maze-runner contains a Ruby logger connected to `STDOUT` that will attempt to log several events that occur during the 
testing life-cycle.  By default, the logger is set to report `INFO` level events or higher, but will log `DEBUG` level 
events if the `VERBOSE` or `DEBUG` flags are set.  If the `QUIET` flag is set it will instead log at the `ERROR` level 
and above.

| Log Level | Event | Information |
|-----------|-------|-------------|
| `DEBUG` | An error occurs when attempting to open a URL | The error information |
| `DEBUG` | When a command is run | The command string, any `STDOUT` and `STDERR` output, and the exit code |
| `DEBUG` | A request is received | The request method, uri, headers and body |
| `WARN` | The server has not received the desired number of requests | The array of received requests |
| `WARN` | Sleep steps are used | A warning to avoid using sleep where possible |
| `WARN` | A Selenium `StaleElementReferenceError` occurs | The error information |
| `WARN` | A run command fails | The output from the command |
| `FATAL` | The webserver is not running at the start of a test | Error notification before exiting |

### Known issues

* Payload field matching for raw string values can be ambiguous when there is a possible regex match (e.g. when using 
"." as a part of an expected value without escaping it).

## Contributing

If steps would be useful for different projects using maze-runner, add them to `lib/features/steps/`. If there are 
useful helper functions, add them to `lib/features/support/*.rb`.

### Running the tests

maze-runner uses test-unit and minunit to bootstrap itself and run the sample app suites in the test fixtures. 
Run `bundle exec rake` to run the suite.
