# Mock Server

## Overview

The mock server is central to every Maze Runner test.  It exposes various HTTP endpoints that replicate those available at bugsnag.com (only conceptually - it doesn't use https and the domains/paths do not match precisely).  Requests received by the mock server are stored in memory and various Cucumber steps are provided for verifying their contents.

Maze Runner also provides the ability to forward any POST requests that it receives to the real Bugsnag backend, allowing errors and other data to be viewed in the dashboard.  For more information see the `--repeater-api-key` option below.

## Command line options

This section highlights some key command line options for controlling the behavior of the mock server.  For the full list of available options run:
```
bundle exec maze-runner --help
```

`--bind-address` - The mock server will bind to the same default address that the Ruby WEBrick server does.

`--port` - The port to listen on.

`--repeater-api-key` - Maze Runner can repeat the POST requests it receives on to bugsnag.com.  This can be useful for:

  - Populating the Bugsnag dashboard with dummy data
  - Identifying gaps in test coverage
  - Testing new features of Bugsnag during development

Set this value to the API key of the desired destination project in the Bugsnag dashboard.  The MAZE_REPEATER_API_KEY environment variable can also be set as an alternative to this option.

# Endpoints

The mock server provides a number of endpoints for test fixture to use:

- `/` - simply responds to every request with a 200 status code
- `/notify` - for `POST`ing Bugsnag errors to for later verification
- `/sessions` - for `POST`ing Bugsnag sessions to for later verification
- `/traces` - for `POST`ing Bugsnag Performance traces to for later verification
- `/builds` - for `POST`ing Bugsnag builds to for later verification
- `/uploads` - for `POST`ing Bugsnag uploads to for later verification
- `/sourcemap`, `react-native-source-map` - for `POST`ing Bugsnag sourcemaps to for later verification
- `/reflect` - provides a mechanism for instructing the server to behave in certain ways (e.g. responding after a specified time delay)
- `/logs` - provides a mechanism for recording and checking log messages
- `/command` - provides a mechanism for feeding instructions and any other information to the test fixture using only HTTP requests instigated by the test fixture.  Essential for platforms that either do not support Appium, or render in such a way that elements are not accessible.
- `/metrics` - provides a mechanism for collecting arbitrary metrics from a test fixture, collating and writing them to a CSV file at the end of a run.
