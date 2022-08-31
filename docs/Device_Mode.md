# Devices Mode

## Using BrowserStack

BrowserStack is used to drive many of the mobile device tests written using maze-runner.  For these tests we can use a
driver class and accompanying set of steps to interface with the BrowserStack AppAutomate server.  `Maze.driver`
can be used to write custom steps using the API provided by the `Appium::Driver` class.

The options needed to create a connection to the Appium server should be passed in via the command line when invoking
Maze Runner.  See `bundle exec maze-runner --help` for details, but the most pertinent are:
-  `--farm=<s>` - Device farm to use: "bs" (BrowserStack) or "local"
-  `--app=<s>` - The app to be installed and run against
-  `--bs-local=<s>` - Path to the BrowserStackLocal binary
-  `--device=<s>` - BrowserStack device to use (a key of Devices.DEVICE_HASH)
-  `--username=<s>` - BrowserStack username
-  `--access-key=<s>` - BrowserStack access key
