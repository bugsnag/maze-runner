# Upgrading Guide

## v7 to v8

### Command line options

A couple of command line options have been renamed for consistency:

`--enable-bugsnag` becomes `--bugsnag` (and `--no-bugsnag`)
`--enable-retries` becomes `--retries` (and `--no-retries`)

### Request lists

Both the p-value and regular trace requests continue to be received by the `/traces` endpoint, but the p-value requests are now stored in their own `RequestList`.  

The following Cucumber steps change as a result:
- `I receive and discard the initial p-value request` renamed to `I receive and discard the initial p_value`
- `I wait to receive {int} {word}` no accepts a `p_value` as the `word` parameter.
- Similarly for `I discard the oldest {word}`.

### Logging

The `VERBOSE` environment variable no longer has any effect on the log level.  Use `TRACE` or `DEBUG` for the two log levels.

## v6 to v7

Support for Sauce Labs has been removed as we are no longer able to test it.

The Appium and Selenium clients are upgraded to versions 12 and 4 respectively.  Note that these enforce the use of W3C
capabilities, although the changes for this will typically be encapsulated within Maze Runner.  The change is considered
breaking as the earliest supported Appium version is now 1.15 (due to the library update).

### RequestList interface change ###

`RequestList.empty?` has been removed, as it was ambiguous whether it applied to all requests received, or just those 
that had not been processed.  It also meant that in general `empty?` was not the same as `size == 0`.  

`size` has also been renamed to `size_remaining` to avoid ambiguity.

## v5 to v6

The version of Cucumber used by Maze Runner has been updated from 3.1.2 to 7.1.0:

* The `AfterConfiguration` hook has been deprecated -  use `InstallPlugin` or `BeforeAll` instead.
* Code outside of any block (typcially in an `env.rb` file) is executed too late, or not at all 
      - move into a suitable hook such as `BeforeAll`
* The `AfterAll` hook has also been added, which could prove used instead of `at_exit`

The following deprecated BrowserStack device names been removed:
* ANDROID_4
* ANDROID_5
* ANDROID_6
* ANDROID_7
* ANDROID_8
* ANDROID_9

The following deprecated Cucumber steps have been removed:

Removed step | Replacement
---|---|
`the request is valid multipart form-data` | `the {word} request is valid multipart form-data`
`all requests are valid multipart form-data` | `all {word} requests are valid multipart form-data`
`the multipart request has {int} fields` | `the {word} multipart request has {int} fields`
`the multipart request has a non-empty body` | `the {word} multipart request has a non-empty body`
`the field {string} for multipart request is not null` | `the payload field {string} is not null`
`the field {string} for multipart request equals {string}` | `the payload field {string} equals {string}`
`the field {string} for multipart request is null` | `the payload field {string} is null`
`the multipart body does not match the JSON file in {string}` | `the {word} multipart body does not match the JSON file in {string}`
`the multipart body matches the JSON file in {string}` | `the {word} multipart body matches the JSON file in {string}`
`the multipart field {string} matches the JSON file in {string}` | `the {word} multipart field {string} matches the JSON file in {string}`

## v4 to v5

Maze Runner has beeb integrated with the Sauce Labs device farm, resulting in some environment variables and command
line options being renamed or removed:

Old variable/option | New variable(s)/option(s)
---|---|
`MAZE_DEVICE_FARM_USERNAME` | `SAUCE_LABS_USERNAME` and `BROWSER_STACK_USERNAME` 
`MAZE_DEVICE_FARM_ACCESS_KEY` | `SAUCE_LABS_ACCESS_KEY` and `BROWSER_STACK_ACCESS_KEY` 

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
