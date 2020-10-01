## Upgrading Guide

### Upgrading from v2 to v3

The `AppAutomateDriver` class has been renamed to `AppiumDriver` and its BrowserStack specific elements
has been moved into a new `BrowserStackUtils` class.  This changes the arguments needed to create an `AppiumDriver`
or `ResilientAppiumDriver` and an extra call is needed to upload the app to BrowserStack:

```ruby

```

Changes to:

```ruby

```

### Upgrading from 2.6.0 to 2.7.0

#### Resilient Appium Driver

The new `ResilientAppiumDriver` class can be used to handle flaky Appium sessions.  It simply wraps each call to an
underlying `AppAutomateDriver` instance, restarting the Appium session in response to any of the following errors:
- Selenium::WebDriver::Error::UnknownError
- Selenium::WebDriver::Error::WebDriverError

To use, simply instantiate in place of `AppAutomateDriver`.  It's also preferable to access the driver via 
`MazeRunner.driver` rather than the global `$driver` variable:

```ruby
AfterConfiguration do |config|
  AppAutomateDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)
  $driver.start_driver
end
```

Becomes:

```ruby
AfterConfiguration do |config|
  ResilientAppiumDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)
  MazeRunner.driver.start_driver
end
```

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

When using the `--separate-sessions` option, Maze Runner will start and stop the driver for you, so the above should be
modified to the following.

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
