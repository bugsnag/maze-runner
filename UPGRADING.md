# Upgrading Guide

## v2 to v3

In v2, a single "request" endpoint received HTTP requests for both errors (notify) and sessions.  In v3 these have 
been separated, meaning:

### Client Configuration

Bugsnag clients must now be configured with different endpoints:
v2
```
config.setEndpoints("http://localhost:9339", "http://localhost:9339")
```
v3:
```
config.setEndpoints("http://localhost:9339/notify", "http://localhost:9339/sessions")
```

### Cucumber steps changed
 
Several Cucumber steps have changed their wording:

Old step | New step
----| -------- | 
I wait to receive a request | I wait to receive an error
I wait to receive {int} request(s) | I wait to receive {int} error(s)
I discard the oldest request | I discard the oldest error
I should receive no requests | I should receive no errors
the {string} header is not null | the error {string} header is not null
the {string} query parameter equals {string} | the error {string} query parameter equals {string}
the {string} query parameter is not null | the error {string} query parameter is not null
the {string} query parameter is a timestamp | the error {string} query parameter is a timestamp

### Cucumber steps removed

The following Cucumber steps are no longer required at the scenario level, as they are included
in the newly worded steps above.

TODO

## Upgrading from 2.6.0 to 2.7.0

### Separate Appium sessions option

If using the new `--separate-sessions` option to have each Cucumber scenario run in its own Appium session, you may
need to review your use of the Appium `$driver` variable.  For example, an `env.rb` file may typically contain some code
to reset the app between scenarios and start/stop the driver at the start and end of the whole run:

```ruby
AfterConfiguration do |config|
  AppAutomateDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)
  $driver.start_driver
end

After do |scenario|
  $driver.reset
end

at_exit do
  $driver.driver_quit
end
```

When using the `--separate-sessions` option, Maze Runner with start and stop the driver for you, so the above should be
modified to:

```ruby
AfterConfiguration do |config|
  AppAutomateDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)
  $driver.start_driver unless MazeRunner.configuration.appium_session_isolation
end

After do |scenario|
  $driver.reset unless MazeRunner.configuration.appium_session_isolation
end

at_exit do
  $driver.driver_quit unless MazeRunner.configuration.appium_session_isolation
end
```
