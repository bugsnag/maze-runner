## Upgrading Guide

### Upgrading from 2.6.0 to 2.7.0

#### Separate Appium sessions option

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
modified to the following.

`MazeRunner.driver` is also preferred to using `$driver` as it wraps the raw driver in a facade with restart-on-error
functionality.

```ruby
AfterConfiguration do |config|
  AppAutomateDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)
  MazeRunner.driver.start_driver unless MazeRunner.configuration.appium_session_isolation
end

After do |scenario|
  MazeRunner.driver.reset unless MazeRunner.configuration.appium_session_isolation
end

at_exit do
  MazeRunner.driver.driver_quit unless MazeRunner.configuration.appium_session_isolation
end
```
