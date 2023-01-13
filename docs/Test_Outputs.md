# Maze Runner Outputs

Maze Runner has a number of outputs:
- The standard Cucumber console output
- `maze_output` directory container various files relating to each scenario
- Logging generated using `$logger` in Ruby code

## `maze_output` folder

Maze Runner will generate a folder for each scenario containing:
- A file for each request type (errors, sessions, traces, etc.) detailing all requests of that type received during the scenario.
- For Appium tests on Android or iOS, the device log (`logcat` or `syslog`).  Due to the overhead of retrieving these, it will only be generated for failed scenarios.

Each scenario folder is organised into a `passed` or `failed` folder immediately beneath `maze_runner`.

## Logging

Maze Runner contains a Ruby logger connected to `STDOUT` that will attempt to log several events that occur during the testing life-cycle.  By default, the logger is set to report `INFO` level events or higher, but will log `DEBUG` level events if the `VERBOSE` or `DEBUG` flags are set.  If the `QUIET` flag is set it will instead log at the `ERROR` level and above.

### Customising the logger

The default log format shows the current time in the format: 'HOUR:MINUTE:SECOND', e.g. "12:30:45"

This can be customised by setting the logger's `datetime_format` attribute, for example to include the current date in log messages:

```ruby
$logger.datetime_format = '%Y-%m-%d %H:%M:%S'
```

The format string must be compatible with [Ruby's `Time.strftime` method](https://rubyapi.org/3.1/o/time#method-i-strftime)

The default log formatter outputs lines with the current time (dimmed), log level and the message. For example:

```
\e[2m[03:04:05]\e[0m DEBUG: an example of a debug message
\e[2m[06:07:08]\e[0m  INFO: this is some information
\e[2m[09:10:11]\e[0m  WARN: a warning
```

This can be customised by setting the logger's `formatter` attribute, for example:

```ruby
$logger.instance.formatter = proc do |severity, time, progname, message|
  "Logging a #{severity} message: '#{message}' at #{time.strftime('%Y-%m-%d %H:%M:%S')}\n"
end
```

See [Ruby's `Logger#formatter` documentation for more information](https://rubyapi.org/3.1/o/logger#formatter)

Note: Maze Runner does not set the `progname`, so it will always be `nil` in a formatter proc unless it is set elsewhere
