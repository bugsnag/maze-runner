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
```diff
- I wait to receive a request
+ asdasd
```

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
