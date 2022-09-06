# Browser Mode

## Overview

Browser mode allows Selenium-based tests to be run on either local or remote browsers using a service such as BitBar,
CrossBrowserTesting or BrowserStack.  Browser mode is invoked by using the `--browser` option, which for remote browsers
expects a symbolic name that maps to an entry in the appropriate device farm's yaml file, for example:

* [BitBar](../lib/maze/browsers_bb.yml)
* [BrowserStack](../lib/maze/farm/browser_stack/browsers.yml)
* [CrossBrowserTesting](../lib/maze/browsers_cbt.yml)

For local browsers, the value given for `--browser` is converted to a symbol and passed directly to 
`Selenium::WebDriver.for`.

## Environment variables

To run tests on a service such as BitBar or BrowserStack you will need an account and set one of the following pairs
of environment variables:

* `BROWSER_STACK_USERNAME`/`BROWSER_STACK_ACCESS_KEY`
* `BITBAR_USERNAME`/`BITBAR_ACCESS_KEY`
* `CBT_USERNAME`/`CBT_ACCESS_KEY`

## Example usage

Run all tests using a local Firefox browser:

```
bundle exec maze-runner --farm=local --browser=firefox
```

Run just the scenarios in `features/device.feature` on BrowserStack using Chrome v72:

```
bundle exec maze-runner --farm=bs --browser=chrome_72 features/device.feature
```
