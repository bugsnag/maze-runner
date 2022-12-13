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

Set this value to the API key of the desired destination project in the Bugsnag dashboard.
