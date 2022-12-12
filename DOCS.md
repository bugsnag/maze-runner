# Maze Runner 🏃

A test runner for validating requests.

## How it works

The test harness launches a mock API which awaits requests from sample applications. Using the runner, each scenario is 
executed and the requests are validated to have to correct fields and values. Uses Gherkin and Cucumber under the hood 
to draft semantic tests.

[Getting Started](./docs/Getting_Started.md)

## Mock server

In all modes of operation, Maze Runner automatically starts an HTTP server that mocks Bugsnag's server endpoint.
This mock server provides a URL for each endpoint that Bugsnag does, allowing it to receive errors, session, builds,
source map uploads and traces.

See [here](./docs/Mock_Server.md) for more details of the options available for controlling the behaviour of the mock 
server.

## Modes of operation

Internally, Maze Runner has the following modes of operation

* [Appium/Devices](./docs/Device_Mode.md) - For running tests with Appium on local Android/iOS device or using a device 
  farm such as Bitbar or BrowserStack.
* [Selenium/Browsers](./docs/Browser_Mode.md) - For running tests with Selenium locally using a browser farm such as 
  Bitbar or BrowserStack.n## Troubleshooting

### Logging

Maze Runner contains a Ruby logger connected to `STDOUT` that will attempt to log several events that occur during the 
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

#### Customising the logger

##### `datetime_format`

The default log format shows the current time in the format: 'HOUR:MINUTE:SECOND', e.g. "12:30:45"

This can be customised by setting the logger's `datetime_format` attribute, for example to include the current date in log messages:

```ruby
Maze::Logger.instance.datetime_format = '%Y-%m-%d %H:%M:%S'
```

The format string must be compatible with [Ruby's `Time.strftime` method](https://rubyapi.org/3.1/o/time#method-i-strftime)

##### `formatter`

The default log formatter outputs lines with the current time (dimmed), log level and the message. For example:

```
\e[2m[03:04:05]\e[0m DEBUG: an example of a debug message
\e[2m[06:07:08]\e[0m  INFO: this is some information
\e[2m[09:10:11]\e[0m  WARN: a warning
```

This can be customised by setting the logger's `formatter` attribute, for example:

```ruby
Maze::Logger.instance.formatter = proc do |severity, time, progname, message|
  "Logging a #{severity} message: '#{message}' at #{time.strftime('%Y-%m-%d %H:%M:%S')}\n"
end
```

See [Ruby's `Logger#formatter` documentation for more information](https://rubyapi.org/3.1/o/logger#formatter)

Note: Maze Runner does not set the `progname`, so it will always be `nil` in a formatter proc unless it is set elsewhere

### Known issues

* Payload field matching for raw string values can be ambiguous when there is a possible regex match (e.g. when using 
"." as a part of an expected value without escaping it).

### Running the tests

maze-runner uses test-unit and minunit to bootstrap itself and run the sample app suites in the test fixtures. 
Run `bundle exec rake` to run the suite.
