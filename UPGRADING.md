## Upgrading Guide

### Upgrading from v2 to v3

v3 contains breaking changes in order to support testing on locally held devices using Appium, as well as device
farms other than BrowserStack.

The Cucumber hooks previously required to initialize the `ResilientAppium`/`AppAutomateDriver` have been moved 
internally, and the following typical code should be removed from the notifier repository's `env.rb` file:

```ruby
AfterConfiguration do |config|	
  ResilientAppiumDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)	
  MazeRunner.driver.start_driver unless MazeRunner.configuration.appium_session_isolation	
end	

After do	
  MazeRunner.driver.reset_with_timeout unless MazeRunner.configuration.appium_session_isolation	
end	

at_exit do	
  MazeRunner.driver.driver_quit unless MazeRunner.configuration.appium_session_isolation	
end
```

Arguments that were passed here to `AppAutomateDriver.new`/`ResilientAppiumDriver.new` should now be 
provided on the command line.  Run `bundle exec bugsnag-maze-runner --help` for full details,but as an example:

```shell script
bundle exec bugsnag-maze-runner \
--app=app/build/outputs/apk/release/app-release.apk \
--farm=bs \
--bs-local=~/BrowserStackLocal
--device=ANDROID_7_1 \
--username=$BROWSER_STACK_USERNAME \
--access-key=$BROWSER_STACK_ACCESS_KEY
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
