# 2.5.0 - TBD

## Enhancements

- Ability to run an HTTP/S proxy added
  [#128](https://github.com/bugsnag/maze-runner/pull/128)

# 2.4.0 - 2020/09/01

## Enhancements

- Retry starting of the mock server in cases of failure
  [#120](https://github.com/bugsnag/maze-runner/pull/120)
- Cucumber hooks consolidated into one file
  [#121](https://github.com/bugsnag/maze-runner/pull/121)
- Notifier builds automatically triggered against new versions of `master`
  [#122](https://github.com/bugsnag/maze-runner/pull/122)
- Use BRANCH_NAME throughout instead of BUILDKITE_BRANCH
  [#123](https://github.com/bugsnag/maze-runner/pull/123)

# 2.3.2 - 2020/08/26

## Fixes

- Remove explicit setting of Appium versions on individual `DEVICE_TYPE`s, introduced in 2.3.0.
  [#119](https://github.com/bugsnag/maze-runner/pull/119)

# 2.3.1 - 2020/08/25

## Fixes

- Fix module load order by requiring Servlet and Logger from Server class
  [#118](https://github.com/bugsnag/maze-runner/pull/118)
- Fix error when parsing request with no body
  [#118](https://github.com/bugsnag/maze-runner/pull/118)

# 2.3.0 - 2020/08/24

## Enhancements

- Update platform comparison step to allow skipping via keywords
  [#109](https://github.com/bugsnag/maze-runner/pull/109)
- Update platform comparison steps to target different parameter types
  [#110](https://github.com/bugsnag/maze-runner/pull/110)
- Add reset_with_timeout method to improve flake resilience
  [#114](https://github.com/bugsnag/maze-runner/pull/114)
- Add Appium restart logic to wait_for_element and reset when Appium errors occur
  [#116](https://github.com/bugsnag/maze-runner/pull/116)

# 2.2.1 - 2020/07/10

## Fixes

- Correct passing of defaulted parameter.
  [#107](https://github.com/bugsnag/maze-runner/pull/107)

# 2.2.0 - 2020/07/10

## Enhancements

- Add ability to clear text from an element.
  [#104](https://github.com/bugsnag/maze-runner/pull/104)
- Provide new step to allow a timeout to be set when waiting for an element to be available.
  [#105](https://github.com/bugsnag/maze-runner/pull/105)
- Provide new step to allow different expected values on different platforms
  [#103](https://github.com/bugsnag/maze-runner/pull/103)

# 2.1.2 - 2020/06/23

## Fixes

- Make --retry and --fail-fast play nicely together by bumping Cucumber to 3.1.2.

# 2.1.1 - 2020/06/22

## Fixes

- Account for --retry being provided when adding --strict option (to allow flaky tests).

# 2.1.0 - 2020/06/04

## Enhancements

- Run Cucumber with strict mode, unless any strict/no-strict option has been set.
- Log all received requests when a Scenario fails.
- Auto-collapse log output for passing scenarios when run using Buildkite.

# 2.0.0

Major new version focused on using Buildkite to run tests on real devices using BrowserStack.

# 1.2.0

Addition of HTTP version steps.

# 1.1.0

Various changes have been made since the 1.0.0 release, but no specific versioning strategy
was not employed.  This minor release encapsulates those changes and no further significant 
changes to the v1 series is expected (v2 already exists and should be used in preference).

# 1.0.0

Initial release
