# Test Inputs

## Command line options

All command line options for Cucumber Ruby are supported by Maze Runner.  To see the full list of options, run `bundle exec maze-runner --help`.

Command line options can also be listed in the following files:
- features/support/maze.all.cfg - included for all test runs.
- features/support/maze.buildkite.cfg - included if the BUILDKITE environment variable is set.

## Environment variables

Maze Runner recognises various environment variables, as follows:

### Mock Server

`MAZE_PORT` - the port to run the mock server on.

### Bugsnag reporting

`MAZE_BUGSNAG_API_KEY` - the API key for the Bugsnag project to which errors that occur during the test run should be reported.
`MAZE_SCENARIO_BUGSNAG_API_KEY` - the API key for the Bugsnag project to which test failures should be reported as errors.

### Device farms

#### Configuration

`MAZE_APPIUM_SERVER` - the Appium server URL (if different to the default).
`MAZE_SELENIUM_SERVER` - the Selenium server URL (if different to the default).

#### BitBar

`MAZE_SB_LOCAL` - location of the SmartBear secure tunnel binary.
`BITBAR_USERNAME`/`BITBAR_ACCESS_KEY` - BitBar account credentials.

`MAZE_REPEATER_API_KEY` - Enables forwarding of all received session, error and trace requests to Bugsnag, using the API key provided.

#### BrowserStack

`MAZE_BS_LOCAL` - location of the BrowserStack secure tunnel binary.

`BROWSER_STACK_USERNAME`/`BROWSER_STACK_ACCESS_KEY` - BrowserStack account credentials.

`BROWSER_STACK_BROWSERS_USERNAME`/`BROWSER_STACK_BROWSERS_ACCESS_KEY` - BrowserStack account credentials for browser tests, used instead of `BROWSER_STACK_USERNAME`/`BROWSER_STACK_ACCESS_KEY` if both are provided.
`BROWSER_STACK_DEVICES_USERNAME`/`BROWSER_STACK_DEVICES_ACCESS_KEY` - BrowserStack account credentials for device tests, used instead of `BROWSER_STACK_USERNAME`/`BROWSER_STACK_ACCESS_KEY` if both are provided.

#### Local devices

`MAZE_APPLE_TEAM_ID` - the Apple Developer Team ID, required for testing on physical iOS devices.
`MAZE_UDID` - the UDID of the physical iOS device to be used for test.
