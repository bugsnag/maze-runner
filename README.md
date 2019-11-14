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

   ```
   gem install bundler
   ```

2. Add a Gemfile to the root of your project:

   ```ruby
   source "https://rubygems.org"

   gem "bugsnag-maze-runner", git: "https://github.com/bugsnag/maze-runner"
   ```

3. Run `bundle install` to fetch and install Maze Runner

4. Run `bundle exec bugsnag-maze-runner init` from the root of your project to build the
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

   ```
   bundle exec bugsnag-maze-runner
   ```

## Writing features

Features should be composed as concisely has possible, reusing existing steps as
needed. The harness provides a number of reusable step definitions for
interacting with scripts, setting environment variables, and inspecting output.
Each new feature should go into a `.feature` file in the `features` directory.

```gherkin
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
 Before do
   clean_build_artifacts
 end

# Run after every scenario
After do |scenario|
  # Teardown scenario configuration here

  if scenario.failed?
    # Can be used to do specific cleanup if a scenario fails
  end
end
```

### Step reference

A quick, non-exhaustive overview of steps that can be used when writing feature files.

#### Field path notation

Anywhere a `{field}`, `{path}`, `{key_path}`, etc is denoted, it can be replaced with dot-delimited key path to indicate the path from the root of an object to the intended target.

For example, to match the name of the second objects in the the key `fruits` below, use `fruits.1.name` as the keypath.

```
{
  "fruits": [
  	{ "name": "apple" },
  	{ "name": "cherry" }
  ]
}
```

#### Script and docker steps

| Step | Description |
|------|-------------|
| I set environment variable `{key}` to `{value}` | Make an environment variable available to any scripts which run afterwards |
| I run the script `{path}` | Runs the file denoted by `path`, which should be relative to the `scripts` directory or custom directory denoted by the `SCRIPT_PATH` environment variable |
| I run the script `{path}` synchronously | As above, but blocks until the script has returned |
| I start the service `{service}` | Starts a docker service from a docker-compose file found at `features/fixtures/docker-compose.yml` |
| I wait for `{time}` second(s) | Pauses execution for the stated time |

#### BrowserStack steps

BrowserStack is used to drive many of the mobile device tests written using maze-runner.  For these tests we can use a driver class and accompanying set of steps to interface with the BrowserStack AppAutomate server.

The driver needs to be started within the `AfterConfiguration` callback in the `features/support/env.rb` file, where the arguments indicate the particular test setup:

```ruby
AfterConfiguration do |config|
  AppAutomateDriver.new(bs_username, bs_access_key, bs_local_id, device_type, app_location)
  $driver.start_driver
end
```

This adds the `$driver` global variable which can be used to write custom steps using the API provided by the `Appium::Driver` class. Several steps are already provided:

| Step | Description |
|------|-------------|
| The element `{element}` is present | Checks that an element matching a specific ID is present on the device screen |
| I click the element `{element}` | Interacts with a visible element on the device screen |
| I send the app to the background for `{timeout}` seconds | Puts the app into a background state for a number of seconds. If sent to the background for 0 seconds, the app will remain there indefinitely |
| I send the keys `{keys}` to the element `{element}` | Writes a string into an on-screen element |

#### Network steps

| Step | Description |
|------|-------------|
| I wait for the host `{host}` to open port `{port}` | Repeatedly attempts to connect to a given port on a host, timing out and stopping the test after a certain period if the port isn't accepting connections |
| I open the URL `{url}` | Sends a request to the given url |

#### API helper steps

The following steps are quick validations that ensure a received payload is valid for whichever API it is being sent to, but checking that specific elements and headers are present.

| Step | Description |
|------|-------------|
| The request is valid for the error reporting API version `{payload_version}` for the `{notifier_name}` notifier | Validates for the error-reporting API for a particular payload version and notifier |
| The request is valid for the Build API | Validates for the Build API |
| The request is valid for the Android Mapping API | Validates for the Android Mapping API |
| The request is valid for the session reporting API version `{payload_version}` for the `{notifier_name}` notifier | Validates for the session-tracking API for a particular payload version and notifier |

#### Handling requests

| Step | Description |
|------|-------------|
| I wait to receive `{request_count}` request(s) | Waits for the number of requests to be received, timing out after 30 seconds |
| I should receive no requests | Verifies that no requests have been received |
| I discard the oldest request | Pops the earliest received request off the stack, enabling access to requests received afterwards |
| The payload field `{path}` is stored as the value `{key}` | Extracts a value found at `path` in the current payload, storing it under the `key` for later use |
| The payload field `{path}` equals the stored value `{key}` | Compares a value found at `path` in the current payload and compares it against a value previously stored under `key` |
| The payload field `{path}` does not equal the stored value `{key}` | Compares a value found at `path` in the current payload and compares it against a value previously stored under `key` |

#### Testing payload values

These steps are a non-exhaustive list of ways to test the values received within a payload. All tests target the oldest received payload, see above for testing multiple requests.

| Step | Description |
|------|-------------|
| The payload field `{key_path}` is `{literal}` | Tests the value matches a literal. Values include `true`, `false`, `null`, `not null` |
| The payload field `{key_path}` equals `{number}` | Tests the value equals a number. Other possible comparisons include `is greater than` and `is less than` |
| The payload field `{key_path}` equals `{string}` | Tests the value equals a string. Other possible comparisons include `starts with` and `ends with` |
| The payload field `{key_path}` is an array with `{number}` elements | Tests an array for size |
| The payload field `{key_path}` matches the regex `{regex}` | Tests the value matches a regex |
| Each element in payload field `{key_path}` has `{internal_path}` | Tests that each element in an array has a valid value at its `internal_path` |

Most of these steps exist in forms that allow for quick testing of event values and session values in predefined places. These prepend a path onto the given key path.  See [`error_reporting_steps`](/lib/features/steps/error_reporting_steps.rb) and [`session_tracking_steps`](/lib/features/steps/session_tracking_steps.rb) for full details.

Similar steps are also available for testing multi-part requests, query parameters, and headers.  See [`request_assertion_steps`](/lib/features/steps/request_assertion_steps.rb) for full details.

#### On matching JSON templates

For the following steps:

```
Then the payload body matches the JSON fixture in "features/fixtures/template.json"
Then the payload field "items.0.subset" matches the JSON fixture in "features/fixtures/template.json"
```

The template file can either be an exact match or specify regex matches for string fields. For example, given the template

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

Run the entire suite using `bundle exec bugsnag-maze-runner`. Alternately, you
can specify specific files to run:

```
bundle exec bugsnag-maze-runner features/something.feature
```

Add the `--verbose` option to print script output and a trace of what Ruby file
is being run.

## Troubleshooting

### Logging

Maze-runner contains a Ruby logger connected to `STDOUT` that will attempt to log several events that occur during the testing life-cycle.
By default the logger is set to report `WARN` level events or higher, but will log `DEBUG` level events if the `VERBOSE` or `DEBUG` flags are set.

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

* Testing on iOS sometimes fails while Android Studio or gradle or some Android
  emulators are running.
* Payload field matching for raw string values can be ambiguous when there is a
  possible regex match (e.g. when using "." as a part of an expected value
  without escaping it).

## Contributing

If steps would be useful for different projects running the maze, add the to
`lib/features/steps/`. If there are useful helper functions, add them to
`lib/features/support/*.rb`.

### Running the tests

bugsnag-maze-runner uses test-unit and minunit to bootstrap itself and run the
sample app suites in the test fixtures. Run `bundle exec rake` to run the suite.
