# Upgrading Guide

## v3 to v4

In v3, a single "request" endpoint received HTTP requests for both errors (notify) and sessions.  In v4 these have 
been separated, meaning:

### Client Configuration

Bugsnag clients must now be configured with different endpoints:
v3
```
config.setEndpoints("http://localhost:9339", "http://localhost:9339")
```
v4:
```
config.setEndpoints("http://localhost:9339/notify", "http://localhost:9339/sessions")
```

### Namespace and class changes

The `MazeRunner` class is renamed to just `Maze` and all other classes have been moved into the `Maze` namespace.

### Cucumber step changes
 
Several Cucumber steps have changed their wording or been split into separate steps.  Where `{word}` is used in these
steps it corresponds to either `error` or `session` (or their plurals).

Old step | New step(s)
----| -------- | 
I wait to receive a request | I wait to receive an error <br> I wait to receive a session
I wait to receive {int} request(s) | I wait to receive {int} error(s) <br> I wait to receive {int} session(s)
I discard the oldest request | I discard the oldest error <br> I discard the oldest session
the {string} header is not null | the {word} {string} header is not null
the {string} header equals {string} | the {word} {string} header equals {string}
the {string} header matches the regex {string} | the {word} {string} header matches the regex {string}
the {string} header equals one of: | the {word} {string} header equals one of:
the {string} header is a timestamp | the {word} {string} header is a timestamp
the {string} query parameter equals {string} | the {word} {string} query parameter equals {string}
the {string} query parameter is not null | the {word} {string} query parameter is not null
the {string} query parameter is a timestamp | the {word} {string} query parameter is a timestamp
the payload field {string} ... <various> | the {word} payload field {string} ...

### Upgrading from v2 to v3

#### Published Docker image

The base Docker image has changed from Alpine to Ubuntu in order to resolve logged errors when running the 
BrowserStackLocal binary.  Any Docker files `FROM` maze-runner will need to be reviewed for anything Alpine-specific.

Also, released images are now pushed to their own ECR repository, maze-runner-releases.

So instead of:
```
FROM 855461928731.dkr.ecr.us-west-1.amazonaws.com/maze-runner:latest-v2-cli
```
You will need:
```
FROM 855461928731.dkr.ecr.us-west-1.amazonaws.com/maze-runner-releases:latest-v3-cli
```

#### Appium driver

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
