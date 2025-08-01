# 9.32.4 - 2025/08/01

## Fixes

- Set metadata token header when retrieving public IP of Docker container [772](https://github.com/bugsnag/maze-runner/pull/772)

## Removals

- Remove reporting of Appium metrics to Datadog. [771](https://github.com/bugsnag/maze-runner/pull/771)

# 9.32.3 - 2025/07/23

## Enhancements

- Remove Android 7 browser support from BS and replace it with Android 8 [770](https://github.com/bugsnag/maze-runner/pull/770)

# 9.32.2 - 2025/07/22

## Fixes

- Update BitBar browser capability from `platform` to `platformName` [769](https://github.com/bugsnag/maze-runner/pull/769)

# 9.32.1 - 2025/07/15

## Removals

- Remove option of ANDROID_7 for BrowserStack device (deprecated device).  Alternatives provided for other deprecations. [768](https://github.com/bugsnag/maze-runner/pull/768)

# 9.32.0 - 2025/06/24

## Enhancements

- Add Hub repeater [767](https://github.com/bugsnag/maze-runner/pull/767)

# 9.31.4 - 2025/06/09

## Fixes

- Remove pin for `uri` standard Gem [766](https://github.com/bugsnag/maze-runner/pull/766)

# 9.31.3 - 2025/06/02

## Enhancements

- Add `unity-line-mappings` endpoint to the mock server [764](https://github.com/bugsnag/maze-runner/pull/764)

# 9.31.2 - 2025/05/29

## Fixes

- Retry BitBar device session creation for `Error executing adbExec` errors [762](https://github.com/bugsnag/maze-runner/pull/762)
- Group Appium session reports on sanitised message [763](https://github.com/bugsnag/maze-runner/pull/763)

# 9.31.1 - 2025/05/19

## Fixes

- Ignore precise milliseconds when grouping errors finding a connected Android device [758](https://github.com/bugsnag/maze-runner/pull/758)
- Avoid double-reporting of Appium errors [759](https://github.com/bugsnag/maze-runner/pull/759)
- Ensure Appium session result is notified before Bugsnag shuts down [760](https://github.com/bugsnag/maze-runner/pull/760)

# 9.31.0 - 2025/05/15

## Enhancements

- Add step `I discard all {request_type}`' [756](https://github.com/bugsnag/maze-runner/pull/756)

## Fixes

- Notify errors that fail the Appium driver [757](https://github.com/bugsnag/maze-runner/pull/757)

# 9.30.3 - 2025/05/14

## Fixes

- Fix crash writing received invalid requests to maze_output [755](https://github.com/bugsnag/maze-runner/pull/755)

# 9.30.2 - 2025/05/13

## Fixes

- Improve grouping of reported Selenium/Appium errors [753](https://github.com/bugsnag/maze-runner/pull/753)
- Correct logging of invalid messages [754](https://github.com/bugsnag/maze-runner/pull/754)

# 9.30.1 - 2025/05/02

## Fixes

- Correct BrowserStack device session link in response to dashboard change [750](https://github.com/bugsnag/maze-runner/pull/750)
- Notify when `terminate_app` falls back to `close_app` [750](https://github.com/bugsnag/maze-runner/pull/750)

# 9.30.0 - 2025/04/29

## Enhancements

- Add Edge 81 on BrowserStack and make corrections to others [747](https://github.com/bugsnag/maze-runner/pull/747)
- Add File Manager API method for pulling Documents/Files directory from mobile devices [749](https://github.com/bugsnag/maze-runner/pull/749)

# 9.29.2 - 2025/04/24

## Fixes

- Correct BrowserStack browser session link in response to dashboard change [746](https://github.com/bugsnag/maze-runner/pull/746)

# 9.29.1 - 2025/04/23

## Fixes

- Remove erroneous use of global variable from browser driver `click_element` [745](https://github.com/bugsnag/maze-runner/pull/745)

# 9.29.0 - 2025/04/17

## Enhancements

- Allow mock server port to be set from the environment [744](https://github.com/bugsnag/maze-runner/pull/744)

# 9.28.0 - 2025/04/15

## Enhancements

- Add `background` to AppManager API [743](https://github.com/bugsnag/maze-runner/pull/743)

## Fixes

- Retry BitBar Appium session creation if beaten to selected device [742](https://github.com/bugsnag/maze-runner/pull/742)

# 9.27.4 - 2025/04/14

## Fixes

- Explicitly fail remaining scenarios if driver fails [741](https://github.com/bugsnag/maze-runner/pull/741)

# 9.27.3 - 2025/04/10

## Fixes

- Fail test run when Appium driver fails [740](https://github.com/bugsnag/maze-runner/pull/740)

# 9.27.2 - 2025/04/07

## Fixes

- Handle Appium `UnknownError` in `AppManager` [738](https://github.com/bugsnag/maze-runner/pull/738)

# 9.27.1 - 2025/04/04

## Fixes

- Removed erroneous warning for failed Appium drivers [735](https://github.com/bugsnag/maze-runner/pull/735)
- Do not use `Maze.driver` directly when performing operations [737](https://github.com/bugsnag/maze-runner/pull/737)

# 9.27.0 - 2025/03/25

## Enhancements

- Add Appium API method for retrieving device logs [732](https://github.com/bugsnag/maze-runner/pull/732)
- Add UiManager to Appium API [733](https://github.com/bugsnag/maze-runner/pull/733)

# 9.26.0 - 2025/03/18

## Enhancements

- Add Appium API method for pressing the Back button [731](https://github.com/bugsnag/maze-runner/pull/731)

# 9.25.0 - 2025/03/06

## Enhancements

- Reporting of Appium session success statuses to Bugsnag [728](https://github.com/bugsnag/maze-runner/pull/728)

## Fixes

- Replace deprecated BrowserStack device Google Pixel 4 for ANDROID_11 [730](https://github.com/bugsnag/maze-runner/pull/730)

## Removals

- Remove Aspecto repeater [729](https://github.com/bugsnag/maze-runner/pull/729)

# 9.24.0 - 2025/03/04

## Enhancements

- Log name of device used in BitBar sessions [726](https://github.com/bugsnag/maze-runner/pull/726)
- Add the `breakpad-symbol` endpoint to the mock server [727](https://github.com/bugsnag/maze-runner/pull/727)

# 9.23.2 - 2025/02/20

## Fixes

- Fix an issue with repeater API keys being valid despite being empty strings [725](https://github.com/bugsnag/maze-runner/pull/725)

# 9.23.1 - 2025/02/19

## Fixes

- Fix issue with the method used to parse the lambda response line [724](https://github.com/bugsnag/maze-runner/pull/724)

# 9.23.0 - 2025/02/18

## Enhancements

- Allow multiple browser options to be presented to BitBar and BrowserStack test runs [712](https://github.com/bugsnag/maze-runner/pull/712)
- Output device information as a JSON file during appium tests [717](https://github.com/bugsnag/maze-runner/pull/717)
- Failed driver guards added to File Manager API [709](https://github.com/bugsnag/maze-runner/pull/709)
- Add App Manager API [712](https://github.com/bugsnag/maze-runner/pull/712)
- Add Device Manager API [712](https://github.com/bugsnag/maze-runner/pull/713)
- Add terminate and activate methods to App Manager API [716](https://github.com/bugsnag/maze-runner/pull/716)

## Fixes

- Do not run Cucumber `Before` and `After` hooks when skipping scenarios [723](https://github.com/bugsnag/maze-runner/pull/723)
- Ensure we parse the correct line from AWS lambda responses [722](https://github.com/bugsnag/maze-runner/pull/722)

# 9.22.0 - 2025/01/08

## Enhancements

- Skip remaining tests after Appium session failure [708](https://github.com/bugsnag/maze-runner/pull/708)
- Add wait_for_element and click_element methods to browser driver [710](https://github.com/bugsnag/maze-runner/pull/710)
- Adjust the URL used for Browserstack Sessions [711](https://github.com/bugsnag/maze-runner/pull/711)

# 9.21.0 - 2024/11/28

## Enhancements

- Ensure selenium related errors are always reported [706](https://github.com/bugsnag/maze-runner/pull/706)

## Fixes

- Fix issue where the incorrect `buildId` was being pulled from `Maze.driver.session_capabilities` [707](https://github.com/bugsnag/maze-runner/pull/707)

# 9.20.0 - 2024/11/21

## Enhancements

- Catch AWS IP invalid response error and attempt to retry [704](https://github.com/bugsnag/maze-runner/pull/704)
- Add iOS 13,14 and 18 mobile browsers on BrowserStack [705](https://github.com/bugsnag/maze-runner/pull/705)

# 9.19.1 - 2024/11/19

## Fixes

- Fix incorrect access of error captor class [703](https://github.com/bugsnag/maze-runner/pull/703)

# 9.19.0 - 2024/11/18

## Enhancements

- Removed deprecated safari 15 & 16 from BitBar configuration, added safari 17 & 18 [701](https://github.com/bugsnag/maze-runner/pull/701)
- Handle failing appium session better [696](https://github.com/bugsnag/maze-runner/pull/696)
- Disable automatic attempts to acquire test device logs in appium scenarios [702](https://github.com/bugsnag/maze-runner/pull/702)

## Fixes

- Add extra guard for stopping running apps in case of remote server error [694](https://github.com/bugsnag/maze-runner/pull/694)

# 9.18.1 - 2024/11/13

## Fixes

- Pin "uri" dependency to avoid v1.0.0 release bug [700](https://github.com/bugsnag/maze-runner/pull/700)

# 9.18.0 - 2024/11/07

## Enhancements

- Ignore system generated ANRs on Android [699](https://github.com/bugsnag/maze-runner/pull/699)

# 9.17.0 - 2024/11/06

## Enhancements

- Add Android 15 to the available BrowserStack devices [697](https://github.com/bugsnag/maze-runner/pull/697)

## Fixes

- Do not set `acceptInsecureCerts` capability with IE [698](https://github.com/bugsnag/maze-runner/pull/698)

# 9.16.0 - 2024-11-01

## Enhancements

- Add https support for document servers [695](https://github.com/bugsnag/maze-runner/pull/695)

# 9.15.1 - 2024-10-29

## Fixes

- Ensure all values are floating points before comparison [693](https://github.com/bugsnag/maze-runner/pull/693)

# 9.15.0 - 2024-10-09

## Enhancements

- Add support for iOS 18 on BrowserStack and remove deprecated devices [680](https://github.com/bugsnag/maze-runner/pull/680)

## Fixes

- Add dependencies for modules no longer present in Ruby standard lib for v3.3+ [678](https://github.com/bugsnag/maze-runner/pull/678)
- Fix issues with loading maze-runner commands from file [679](https://github.com/bugsnag/maze-runner/pull/679)
- Remove deprecated close_app usage [681](https://github.com/bugsnag/maze-runner/pull/681)

# 9.14.0 - 2024-09-23

## Enhancements

- Add the ability to override the `--fail-fast` option via an environment variable [674](https://github.com/bugsnag/maze-runner/pull/674)
- Add support for defining custom validation blocks in configuration
  - [672](https://github.com/bugsnag/maze-runner/pull/672)
  - [675](https://github.com/bugsnag/maze-runner/pull/675)
  - [677](https://github.com/bugsnag/maze-runner/pull/677)
- Add client mode configuration option [677](https://github.com/bugsnag/maze-runner/pull/677)
- Add support for command line options files [676](https://github.com/bugsnag/maze-runner/pull/676)

# 9.13.1 - 2024-08-30

## Fixes

- Repeat trace requests using the API key as the subdomain [670](https://github.com/bugsnag/maze-runner/pull/670)

# 9.13.0 - 2024-08-14

## Enhancements

- Add the ability to disable timestamp validation for spans [659](https://github.com/bugsnag/maze-runner/pull/659)
- Add support for unmanaged traces [669](https://github.com/bugsnag/maze-runner/pull/669)

# 9.12.0 - 2024-07-31

## Enhancements

- Add tool to find failed BitBar sessions and save them to a CSV file [665](https://github.com/bugsnag/maze-runner/pull/665)
- Add regex-based variants of steps for checking platform-dependent values [667](https://github.com/bugsnag/maze-runner/pull/667)

## Fixes

- Add better appium driver exits on server error [666](https://github.com/bugsnag/maze-runner/pull/666)

# 9.11.2 - 2024/07/18

## Fixes

- Bump `curb` dependency to 1.0.5 [664](https://github.com/bugsnag/maze-runner/pull/664)

# 9.11.1 - 2024/07/15

## Fixes

- Move iOS 15 BrowserStack tests from iPhone 11 Pro to iPhone 13 [662](https://github.com/bugsnag/maze-runner/pull/662)
- Reinstate publishing of legacy CLI Docker image [663](https://github.com/bugsnag/maze-runner/pull/663)

# 9.11.0 - 2024/07/05

## Enhancements

- add support for comparing double and array attributes in spans [661](https://github.com/bugsnag/maze-runner/pull/661)

# 9.10.0 - 2024/07/02

## Enhancements

- Add Android 14 to the available BrowserStack devices [658](https://github.com/bugsnag/maze-runner/pull/658)

# 9.9.1 - 2024/06/22

## Fixes

- Update appium server to remove command vulnerability [653](https://github.com/bugsnag/maze-runner/pull/653)
- Improve handling of Selenium `ServerError`s [6553](https://github.com/bugsnag/maze-runner/pull/655)

# 9.9.0 - 2024/05/08

## Enhancements

- Adds step to allow testing of a set of properties in a named span [651](https://github.com/bugsnag/maze-runner/pull/651)
- Update AWS SAM functionality to work with a newer version of SAM CLI [652](https://github.com/bugsnag/maze-runner/pull/652)

# 9.8.0 - 2024/05/02

## Enhancements

- Adds further retries for 'unknown errors' received by appium attempting to start a test session.[645](https://github.com/bugsnag/maze-runner/pull/645)
- Use deviceGroupId capability to acquire device in BitBar tests where appropriate [646](https://github.com/bugsnag/maze-runner/pull/646)
- Serve documents from `/docs` on primary port [650](https://github.com/bugsnag/maze-runner/pull/650)

## Fixes

- Ensure appium:options are in the correct place for each version of appium [647](https://github.com/bugsnag/maze-runner/pull/647)

# 9.7.0 - 2024/04/08

## Enhancements

- Allow command servlet to respond appropriately when given UUID from previous test [643](https://github.com/bugsnag/maze-runner/pull/643)

## Fixes

- Only zip maze_output if file_log is on [#644](https://github.com/bugsnag/maze-runner/pull/644)

# 9.6.0 - 2024/04/03

## Enhancements

- Add bugsnag middleware to group ambiguous errors differently [640](https://github.com/bugsnag/maze-runner/pull/640)

## Removals

- Remove various unsupported BrowserStack devices [641](https://github.com/bugsnag/maze-runner/pull/641)

# 9.5.0 - 2024/03/12

## Enhancements

- Update reflective server to store and output received requests [639](https://github.com/bugsnag/maze-runner/pull/639)

# 9.4.0 - 2024/03/07

## Enhancements

- Forward port 8.19.0 to 8.20.1 to v9 [638](https://github.com/bugsnag/maze-runner/pull/638)

# 9.3.1 - 2024/03/06

## Fixes

- Remove blanket check on `service.version` in trace requests [637](https://github.com/bugsnag/maze-runner/pull/637)

# 9.3.0 - 2024/02/28

## Enhancements

- Add new span validation steps [630](https://github.com/bugsnag/maze-runner/pull/630)

## Fixes

- Add CodeQL fixes [632](https://github.com/bugsnag/maze-runner/pull/632)
- Ensure app_id is set correctly on BrowserStack test runs [633](https://github.com/bugsnag/maze-runner/pull/633)
- Add missing retry logic for appium downstream proxy error [636](https://github.com/bugsnag/maze-runner/pull/636)

# 9.2.1 - 2024/02/16

## Fixes

- Fall back to `close_app` if `terminate_app` fails [631](https://github.com/bugsnag/maze-runner/pull/631)

# 9.2.0 - 2024/02/15

## Enhancements

- Add additional symbol file upload endpoint [629](https://github.com/bugsnag/maze-runner/pull/629)

# 9.1.0 - 2024/01/26

## Enhancements

- Forward port 8.17.0 to 8.18.0 to v9 fork [625](https://github.com/bugsnag/maze-runner/pull/625)

# 9.0.0 - 2024/01/17

## Enhancements

- Remove use of deprecated `Maze.driver.reset` in BitBar Appium tests [607](https://github.com/bugsnag/maze-runner/pull/607)
- Clear request lists while the app is stopped [619](https://github.com/bugsnag/maze-runner/pull/619)

# 8.20.1 - 2024/02/29

## Fixes

- Ensure app_id is set correctly on BrowserStack test runs [634](https://github.com/bugsnag/maze-runner/pull/634)
- Add missing retry logic for appium downstream proxy error [635](https://github.com/bugsnag/maze-runner/pull/635)

# 8.20.0 - 2024/02/16

## Enhancements

- Add exit code for app-hang errors occurring in appium [628](https://github.com/bugsnag/maze-runner/pull/628)

# 8.19.0 - 2024/02/08

## Enhancements

- Re-enable bugsnag reporting test failures when MAZE_SCENARIO_BUGSNAG_API_KEY environment variable is present [626](https://github.com/bugsnag/maze-runner/pull/626)

# 8.18.0 - 2024/01/26

## Enhancements

- Allow Appium version to be set on BitBar [624](https://github.com/bugsnag/maze-runner/pull/624)

# 8.17.1 - 2024/01/24

## Fixes

- Move appium session information to at_exit block to always run, even on maze-runner crash [623](https://github.com/bugsnag/maze-runner/pull/623)

# 8.17.0 - 2024/01/24

## Enhancements

- Split logging into STDOUT and File loggers, for more information during test runs [618](https://github.com/bugsnag/maze-runner/pull/618)
- Retry BitBar device session creation for `Appium Settings app is not running` error [622](https://github.com/bugsnag/maze-runner/pull/622)

# 8.16.0 - 2024/01/17

## Enhancements

- Add method to allow pulling of files via appium client [617](https://github.com/bugsnag/maze-runner/pull/617)

# 8.15.0 - 2024/01/03

## Enhancements

- Add `--app-package` and `--app-activity` options (used for BitBar Appium tests only) [616](https://github.com/bugsnag/maze-runner/pull/616)

# 8.14.1 - 2023/12/21

## Fixes

- Use Buildkite retry count correctly in BitBar test run names [614](https://github.com/bugsnag/maze-runner/pull/614)

# 8.14.0 - 2023/12/18

## Enhancements

- Add idempotent command endpoints [613](https://github.com/bugsnag/maze-runner/pull/613)

# 8.13.2 - 2023/11/29

## Fixes

- Set `autoAcceptAlerts` in iOS Appium tests [611](https://github.com/bugsnag/maze-runner/pull/611)

# 8.13.1 - 2023/11/20

## Fixes

- Increase `uiautomator2ServerLaunchTimeout` to 60s on BitBar [610](https://github.com/bugsnag/maze-runner/pull/610)

# 8.13.0 - 2023/11/17

## Enhancements

- Modify retry logic for app upload failures and BitBar appium failures [608](https://github.com/bugsnag/maze-runner/pull/608)

## Fixes

- Work around Event Machine issues on ARM macOS [606](https://github.com/bugsnag/maze-runner/pull/609)

# 8.12.1 - 2023/11/09

## Fixes

- Add appium options to the base capabilities dictionary [606](https://github.com/bugsnag/maze-runner/pull/606)

# 8.12.0 - 2023/11/07

## Enhancements

- Notify errors that occur in Appium or Browser hooks [605](https://github.com/bugsnag/maze-runner/pull/605)

# 8.11.0 - 2023/11/03

## Enhancements

- Write received sampling requests to `maze_output` folder [604](https://github.com/bugsnag/maze-runner/pull/604)

# 8.10.2 - 2023/10/27

## Fixes

- Fix crash when logging message for invalid requests [602](https://github.com/bugsnag/maze-runner/pull/602)
- Fix crash when BUILDKITE_JOB_ID is not set [603](https://github.com/bugsnag/maze-runner/pull/603)

# 8.10.1 - 2023/10/25

## Fixes

- Correct error handling logic on BrowserStack [601](https://github.com/bugsnag/maze-runner/pull/601)

# 8.10.0 - 2023/10/25

## Enhancements

- Add appium options in more than one place to work with older appium servers [599](https://github.com/bugsnag/maze-runner/pull/599)
- Selectively retry creation of BitBar Appium sessions depending on the error encountered [600](https://github.com/bugsnag/maze-runner/pull/600)

## Fixes

- Reinstate `retry_start_driver?` in `LocalClient` [598](https://github.com/bugsnag/maze-runner/pull/598)

# 8.9.0 - 2023/10/19

## Enhancements

- Allow BB browser versions to be set via the command line [593](https://github.com/bugsnag/maze-runner/pull/593)
- Set default test timeout on BitBar selenium runs to 900 seconds [595](https://github.com/bugsnag/maze-runner/pull/595)
- Add the Buildkite job URL to the metadata reported to Bugsnag [597](https://github.com/bugsnag/maze-runner/pull/597)

## Fixes

- Avoid shell interpretation of characters in file names in `Maze::MacosUtils.capture_screen` [594](https://github.com/bugsnag/maze-runner/pull/594)
- Upgrade APT packages used within the Docker images to fix several vulnerabilities reported by AWS ECR scanning [596](https://github.com/bugsnag/maze-runner/pull/596)

# 8.8.0 - 2023/10/11

## Enhancements

- Add iOS 17 to the available BS devices [592](https://github.com/bugsnag/maze-runner/pull/592)

## Fixes

- Increase `uiautomator2ServerInstallTimeout` to 60s on BitBar [590](https://github.com/bugsnag/maze-runner/pull/590)

# 8.7.1 - 2023/09/27

## Fixes

- Internal reporting and logging improvements [587](https://github.com/bugsnag/maze-runner/pull/587)

# 8.7.0 - 2023/09/26

## Enhancements

- Incorporate reporting of internal errors to BugSnag [586](https://github.com/bugsnag/maze-runner/pull/586)

## Fixes

- Use `BITBAR_ACCESS_KEY` universally (only affects `purge-projects` entry point) [585](https://github.com/bugsnag/maze-runner/pull/585)

# 8.6.0 - 2023/09/15

## Enhancements

- Return specific exit code for Appium session creation failures [584](https://github.com/bugsnag/maze-runner/pull/584)

## Fixes

- Improve grouping and presentation of BugSnagged errors [583](https://github.com/bugsnag/maze-runner/pull/583)

# 8.5.0 - 2023/09/05

## Enhancements

- Set `appium:` as the default prefix when running BitBar tests for appium 2.0 compatibility [582](https://github.com/bugsnag/maze-runner/pull/582)

# 8.4.1 - 2023/08/29

## Fixes

- Allow `Bugsnag-Uncompressed-Content-Length` in CORS header policy [581](https://github.com/bugsnag/maze-runner/pull/581)

# 8.4.0 - 2023/08/18

## Enhancements

- Allow `FileManager.write_app_file` target location to be overwritten for Android  [580](https://github.com/bugsnag/maze-runner/pull/580)

## Fixes

- Move the `maze_output.zip` file to the `maze_output` folder once created [579](https://github.com/bugsnag/maze-runner/pull/579)

# 8.3.0 - 2023/08/14

## Enhancements

- Add received span steps to allow greater flexibility in performance tests [571](https://github.com/bugsnag/maze-runner/pull/571) [572](https://github.com/bugsnag/maze-runner/pull/572)
- Check that required trace headers are present and valid [573](https://github.com/bugsnag/maze-runner/pull/573)
- Create zip archive of `maze_output` folder [575](https://github.com/bugsnag/maze-runner/pull/575)

## Fixes

- Replace deprecated BrowserStack Samsung Galaxy S8 Plus device with Samsung Galaxy S8 [576](https://github.com/bugsnag/maze-runner/pull/576)

# 8.2.0 - 2023/07/19

## Enhancements

- Add mechanism to allow hooks before scenario has completed in full [569](https://github.com/bugsnag/maze-runner/pull/569)
- Add additional sourcemap endpoints [570](https://github.com/bugsnag/maze-runner/pull/570)

# 8.1.4 - 2023/07/05

## Fixes

- Correct logic for HTTP response codes to session requests [567](https://github.com/bugsnag/maze-runner/pull/567)

# 8.1.3 - 2023/07/03

## Fixes

- Include traces in request types to set the HTTP response code for [566](https://github.com/bugsnag/maze-runner/pull/566)

# 8.1.2 - 2023/06/30

## Fixes

- Only set HTTP response code for specific request types [565](https://github.com/bugsnag/maze-runner/pull/565)

# 8.1.1 - 2023/06/22

## Fixes

- Sensible timeout for BitBar Appium sessions [564](https://github.com/bugsnag/maze-runner/pull/564)

# 8.1.0 - 2023/06/21

## Enhancements

- Fixes and enhancements to logging of received requests [558](https://github.com/bugsnag/maze-runner/pull/558)

## Fixes

- Fix order of assertion parameters [559](https://github.com/bugsnag/maze-runner/pull/559)
- Fix delete project function in `purge-projects` command [560](https://github.com/bugsnag/maze-runner/pull/560)
- Do not reset driver with Appium 1.15/1.16 [561](https://github.com/bugsnag/maze-runner/pull/561)

# 8.0.2 - 2023/06/15

## Fixes

- Correct capability for Chrome 43 on BitBar [556](https://github.com/bugsnag/maze-runner/pull/556)
- Prevent `Maze.driver.unlock` from raising an error [557](https://github.com/bugsnag/maze-runner/pull/557)

# 8.0.1 - 2023/06/14

## Fixes

- Correct implementation of `the error is a valid browser payload for the error reporting API` [555](https://github.com/bugsnag/maze-runner/pull/555)

# 8.0.0 - 2023/06/13

## Enhancements

- Command line options reviewed for consistency [533](https://github.com/bugsnag/maze-runner/pull/533)
- Upgrade Docker image to Ruby 3 [534](https://github.com/bugsnag/maze-runner/pull/534)
- Update logger to provide a real TRACE level [536](https://github.com/bugsnag/maze-runner/pull/536)
- Filter sampling requests into their own `RequestList` [537](https://github.com/bugsnag/maze-runner/pull/537)
- Shorten BrowserStack Android device names for consistency [538](https://github.com/bugsnag/maze-runner/pull/538)
- Reword header to `is present` rather than `is null` [540](https://github.com/bugsnag/maze-runner/pull/540)
- Rename BrowserStack mobile browsers to OS and version format [545](https://github.com/bugsnag/maze-runner/pull/545)
- Set `--expand` Cucumber option by default [548](https://github.com/bugsnag/maze-runner/pull/548)
- Add step `I set the device orientation to {orientation}` [551](https://github.com/bugsnag/maze-runner/pull/551)
- Avoid the need for quotes around integer lists [550](https://github.com/bugsnag/maze-runner/pull/550) [552](https://github.com/bugsnag/maze-runner/pull/552)
- Add standalone `purge-projects` executable [546](https://github.com/bugsnag/maze-runner/pull/546)

# 7.33.0 - 2023/05/25

## Enhancements

- Add iOS 16 and an up to date Android device browsers to the available BS devices [544](https://github.com/bugsnag/maze-runner/pull/544)

## Fixes

- Output received traces to stdout when a scenario fails [543](https://github.com/bugsnag/maze-runner/pull/543)

# 7.32.0 - 2023/05/19

## Enhancements

- Set BitBar dashboard project and test run for browser tests [542](https://github.com/bugsnag/maze-runner/pull/542)

# 7.31.0 - 2023/05/19

## Enhancements

- Add `Maze.config.receive_requests_slow_threshold` to warn for slow receipt of requests [541](https://github.com/bugsnag/maze-runner/pull/541)

# 7.30.2 - 2023/05/18

## Fixes

- Only enforce Bugsnag integrity header on session, error and trace requests [539](https://github.com/bugsnag/maze-runner/pull/539)

# 7.30.1 - 2023/05/13

## Fixes

- Correct setting of headers on repeated requests [532](https://github.com/bugsnag/maze-runner/pull/532)

# 7.30.0 - 2023/05/11

## Enhancements

- Allow a list of BitBar device groups to be selected from [530](https://github.com/bugsnag/maze-runner/pull/530)
- Forward trace requests to Aspecto [531](https://github.com/bugsnag/maze-runner/pull/531)

# 7.29.0 - 2023/05/09

## Enhancements

- Update appium capabilities for appium 2.0 compatibility [512](https://github.com/bugsnag/maze-runner/pull/512)
- Add support for Edge latest on BrowserStack [528](https://github.com/bugsnag/maze-runner/pull/528)

## Fixes

- Only use separate BitBar accounts on CI [526](https://github.com/bugsnag/maze-runner/pull/526)
- Ensure BitBar apiKey is provided when using the tunnel [527](https://github.com/bugsnag/maze-runner/pull/527)
- Correct setting of `newCommandTimeout` capability for BitBar Appium sessions [529](https://github.com/bugsnag/maze-runner/pull/529)

# 7.28.0 - 2023/05/02

## Enhancements

- Provide access to document server via AWS public IP addresses [525](https://github.com/bugsnag/maze-runner/pull/525)

# 7.27.0 - 2023/04/25

## Enhancements

- Allow BitBar Selenium server URL to be configured [524](https://github.com/bugsnag/maze-runner/pull/524)
- Improve JSON schema validation failure messages [516](https://github.com/bugsnag/maze-runner/pull/516)

## Fixes

- Refactor schema validation and add it to span expectation step [520](https://github.com/bugsnag/maze-runner/pull/520)

## Removals

- Remove absolute browser versions no longer supported by BitBar [523](https://github.com/bugsnag/maze-runner/pull/523)

# 7.26.1 - 2023/04/20

## Fixes

- Fix crash when trying to retry browser tests [515](https://github.com/bugsnag/maze-runner/pull/515)
- Fix crash when BitBar credentials cannot be fetched [513](https://github.com/bugsnag/maze-runner/pull/513)
- Allow JS to access the sampling header [517](https://github.com/bugsnag/maze-runner/pull/517)
- Fail upload-app with non-zero exit code if access key not given [518](https://github.com/bugsnag/maze-runner/pull/518)
- Ensure ids for apps uploaded to BitBar can be read from file [519](https://github.com/bugsnag/maze-runner/pull/519)
- Fix crash in Selenium `LocalClient` caused by unimplemented method [521](https://github.com/bugsnag/maze-runner/pull/521)

# 7.26.0 - 2023/04/12

## Enhancements

- Add step to assert parent-child span relationships [510](https://github.com/bugsnag/maze-runner/pull/510)

## Fixes

- Fix issue causing nil access errors in some span steps [514](https://github.com/bugsnag/maze-runner/pull/514)

# 7.25.0 - 2023/04/05

## Enhancements

- Add `/metrics` endpoint [509](https://github.com/bugsnag/maze-runner/pull/509)
- Set default verb for HTTP status code steps to "POST" [506](https://github.com/bugsnag/maze-runner/pull/506)

# 7.24.0 - 2023/03/30

## Enhancements

- Add logic for step `a span field {string} equals {int}` [501](https://github.com/bugsnag/maze-runner/pull/501)
- Update upload-app script to allow BitBar uploads [504](https://github.com/bugsnag/maze-runner/pull/504)
- Add Datadog StatsD metric reporting for BitBar devices [503](https://github.com/bugsnag/maze-runner/pull/503)
- Add Datadog StatsD metric reporting appium test amounts [505](https://github.com/bugsnag/maze-runner/pull/505)
- Add logged links for selenium test sessions [507](https://github.com/bugsnag/maze-runner/pull/507)

## Fixes

- Improve logging when calculating BitBar dashboard project and test run [501](https://github.com/bugsnag/maze-runner/pull/502)
- Use `URI.open` directly instead of `Kernel.open` [508](https://github.com/bugsnag/maze-runner/pull/508)

# 7.23.0 - 2023/03/20

## Enhancements

- Add extra step to test if a particular span exists in a set a of trace payloads [499](https://github.com/bugsnag/maze-runner/pull/499)

# 7.22.1 - 2023/03/13

## Fixes

- Fix wait for the SBSecureTunnel stopping [495](https://github.com/bugsnag/maze-runner/pull/495)
- Add missing passthrough for the initial sampling value trace payload [496](https://github.com/bugsnag/maze-runner/pull/496)

# 7.22.0 - 2023/03/10

## Enhancements

- Add Edge 80, Firefox 60 & Safari 11 to BrowserStack browser list [493](https://github.com/bugsnag/maze-runner/pull/493)
- Add further validation for trace payloads [489](https://github.com/bugsnag/maze-runner/pull/489)

# 7.21.0 - 2023/03/09

## Enhancements

- Add 'latest' versions of Chrome, Firefox & Edge to BitBar browser list [490](https://github.com/bugsnag/maze-runner/pull/490)

## Fixes

- Fix integer attribute step looking at stringValue [487](https://github.com/bugsnag/maze-runner/pull/487)
- Set all headers present when repeating requests to Bugsnag [488](https://github.com/bugsnag/maze-runner/pull/488)

# 7.20.1 - 2023/03/07

## Fixes

- Start the document server after client hooks run so the document root can be set with other Maze Runner configuration [484](https://github.com/bugsnag/maze-runner/pull/484)
- Add missing Bugsnag-Span-Sampling header to Access-Control-Allow-Headers [485](https://github.com/bugsnag/maze-runner/pull/485)

# 7.20.0 - 2023/02/28

## Enhancements

- Add --list-devices option for BitBar devices and device groups
  - [480](https://github.com/bugsnag/maze-runner/pull/480)
  - [481](https://github.com/bugsnag/maze-runner/pull/481)
- Add BitBar browsers to those currently available [483](https://github.com/bugsnag/maze-runner/pull/483)
  - Firefox 78
  - Chrome 43 and 72

## Removals

- Remove support for all Android 4 to 6 devices on BrowserStack [482](https://github.com/bugsnag/maze-runner/pull/482)

# 7.19.0 - 2023/02/22

## Enhancements
 
- Add link to BitBar dashboard for each Appium session [470](https://github.com/bugsnag/maze-runner/pull/470)
- Set Appium capabilities for the BitBar dashboard [471](https://github.com/bugsnag/maze-runner/pull/471)
- Clean exit for user readable errors [474](https://github.com/bugsnag/maze-runner/pull/474)
- Allow `--device` to specify a device (rather than device group) on BitBar [475](https://github.com/bugsnag/maze-runner/pull/475)

## Fixes

- Set capabilities needed for iOS devices on BitBar (with Appium 1.22) [466](https://github.com/bugsnag/maze-runner/pull/466)
- Tidy capabilities for BitBar devices [473](https://github.com/bugsnag/maze-runner/pull/473)

# 7.18.1 - 2023/02/21

## Fixes
 
- Correct logic for step `a span field {string} matches the regex {string}` [476](https://github.com/bugsnag/maze-runner/pull/476)

# 7.18.0 - 2023/02/10

## Enhancements

- Add iOS 11 and 12 browsers on BrowserStack. [469](https://github.com/bugsnag/maze-runner/pull/469)

# 7.17.0 - 2023/01/31

## Enhancements

- Associate `--device` with device groups on BitBar and remove the need to provide `--os`/`--os-version` options. [465](https://github.com/bugsnag/maze-runner/pull/465)
- Acquire device capabilities each time a driver start is attempted. Add Randomness to device selection to reduce likelihood of race conditions. [467](https://github.com/bugsnag/maze-runner/pull/467)

# 7.16.0 - 2023/01/30

## Enhancements

- Remove use of the TMS for BitBar Appium sessions on CI [464](https://github.com/bugsnag/maze-runner/pull/464)

# 7.15.0 - 2023/01/27

## Enhancements

- Add support for non-JSON content types to the reflective servlet [463](https://github.com/bugsnag/maze-runner/pull/463)

# 7.14.2 - 2023/01/27

## Fixes

- Set `newCommandTimout` to 0 for BitBar Appium sessions [462](https://github.com/bugsnag/maze-runner/pull/462)

# 7.14.1 - 2023/01/26

## Fixes

- Set missing CORS headers for OPTIONS requests in reflective servlet [461](https://github.com/bugsnag/maze-runner/pull/461)

# 7.14.0 - 2023/01/25

## Enhancements

- Added a step to assert that no spans have been received [460](https://github.com/bugsnag/maze-runner/pull/460)

# 7.13.1 - 2023/01/24

## Fixes

- Only push test fixture config file on mobile and not in legacy mode [459](https://github.com/bugsnag/maze-runner/pull/459)

# 7.13.0 - 2023/01/23

## Enhancements

- Push test fixture config file containing Maze Runner address for Appium tests [456](https://github.com/bugsnag/maze-runner/pull/456) [458](https://github.com/bugsnag/maze-runner/pull/458)
- Add reflective servlet to main mock server [457](https://github.com/bugsnag/maze-runner/pull/457)

# 7.12.0 - 2023/01/13

## Enhancements

- Generate and use a single "run UUID" throughout the app [451](https://github.com/bugsnag/maze-runner/pull/451)
- Add `--aws-public-ip` option [452](https://github.com/bugsnag/maze-runner/pull/452)
- Get device logs for failed scenarios [453](https://github.com/bugsnag/maze-runner/pull/453)
- Add steps for verifying traces and spans [454](https://github.com/bugsnag/maze-runner/pull/454)

## Fixes

- Only set `project` and `build` capabilities for BrowserStack [450](https://github.com/bugsnag/maze-runner/pull/450)

# 7.11.0 - 2023/01/06

## Enhancements

- Add support for `docker compose cp` commands [445](https://github.com/bugsnag/maze-runner/pull/445)
- Add steps for checking floating point values in error payloads [448](https://github.com/bugsnag/maze-runner/pull/448)

## Fixes

- Fix legacy mode for browser testing [449](https://github.com/bugsnag/maze-runner/pull/449)

# 7.10.2 - 2023/01/05

## Fixes

- Fix error in step `I have received at least {int} {word}` [442](https://github.com/bugsnag/maze-runner/pull/442)
- Decode all Gzipped POST requests [447](https://github.com/bugsnag/maze-runner/pull/447)

## Refactor

- Refactor Selenium framework code into new class hierarchy in `Maze::Client::Selenium` [444](https://github.com/bugsnag/maze-runner/pull/444)
- Refactor starting of Appium client `Maze::Client::Appium` [446](https://github.com/bugsnag/maze-runner/pull/446)

# 7.10.1 - 2022/12/15

## Fixes

- Correct capabilities for Safari 16 on BrowserStack [441](https://github.com/bugsnag/maze-runner/pull/441)

# 7.10.0 - 2022/12/15

## Enhancements

- Add `--tunnel` (and `--no-tunnel`) option [431](https://github.com/bugsnag/maze-runner/pull/431)
- Add support for running `docker compose exec` commands [425](https://github.com/bugsnag/maze-runner/pull/425)
- Add steps for checking an event has a specific number of breadcrumbs, or no breadcrumbs at all [433](https://github.com/bugsnag/maze-runner/pull/433)
- Simplify logger format [437](https://github.com/bugsnag/maze-runner/pull/437)
- Add `--repeater` option [438](https://github.com/bugsnag/maze-runner/pull/438)
- Add Safari 16 on BrowserStack [440](https://github.com/bugsnag/maze-runner/pull/440)

## Fixes

- Relax check on React Native Notifier name [432](https://github.com/bugsnag/maze-runner/pull/432)
- Add missing assertion against the breadcrumb name in "the event has a {string} breadcrumb named {string}" step [435](https://github.com/bugsnag/maze-runner/pull/435)
- Refactor schema validation to use JSON-schemer [436](https://github.com/bugsnag/maze-runner/pull/436)
- Retry BrowserStack app upload on `Net::ReadTimeout` [439](https://github.com/bugsnag/maze-runner/pull/439)

# 7.9.0 - 2022/12/07

## Enhancements

- Use `docker compose` instead of `docker-compose` [429](https://github.com/bugsnag/maze-runner/pull/429)
- Bump BitBar browsers to those currently available [430](https://github.com/bugsnag/maze-runner/pull/430)
  - Firefox 102 to 107
  - Chrome 103 to 108
  - Edge 101 to 106
  - Safari 15 to 16

# 7.8.0 - 2022/12/05

## Enhancements

- Add additional step for breadcrumb tests, and refactor old steps for consistency [428](https://github.com/bugsnag/maze-runner/pull/428)
- Add schema validation for endpoints based on json-schema [416](https://github.com/bugsnag/maze-runner/pull/416)

# 7.7.0 - 2022/11/30

## Enhancements
  
- Allow HTTP response codes to be set for a series of requests [424](https://github.com/bugsnag/maze-runner/pull/424)
- Allow sampling probability header to be set for a series of requests [426](https://github.com/bugsnag/maze-runner/pull/426)

## Refactor

- Refactor response delay steps to use `Maze::Generator` [427](https://github.com/bugsnag/maze-runner/pull/427)

# 7.6.0 - 2022/11/11

## Enhancements

- Add `/trace` endpoint [402](https://github.com/bugsnag/maze-runner/pull/402)
- Add steps to set sampling probably response header [419](https://github.com/bugsnag/maze-runner/pull/419)
- Log device UDID on BrowserStack [418](https://github.com/bugsnag/maze-runner/pull/418)
- Add support for iOS 16 on BrowserStack [422](https://github.com/bugsnag/maze-runner/pull/422)

## Fixes

- Provide more intuitive message for Maze.check.match failures [417](https://github.com/bugsnag/maze-runner/pull/417)

# 7.5.1 - 2022/11/01

## Fixes

- Correct setting of Maze.config.os_version in W3C mode [415](https://github.com/bugsnag/maze-runner/pull/415)

# 7.5.0 - 2022/10/26

## Enhancements

- Reinstate support for JSON-WP with BrowserStack browsers [414](https://github.com/bugsnag/maze-runner/pull/414)

## Fixes

- Various fixes having updated bugsnag-android [413](https://github.com/bugsnag/maze-runner/pull/413)

# 7.4.0 - 2022/10/20

## Enhancements

- Add error code handling for pipeline management [406](https://github.com/bugsnag/maze-runner/pull/406)
- Add step `I wait to receive at least {int} {word}` [411](https://github.com/bugsnag/maze-runner/pull/411)

## Removals

- Remove support for Google Pixel-8.0 on BrowserStack (deprecated by them) [412](https://github.com/bugsnag/maze-runner/pull/412)
  
# 7.3.0 - 2022/10/17

## Enhancements

- Add steps to enable specific status codes for given payload type [409](https://github.com/bugsnag/maze-runner/pull/409)

# 7.2.3 - 2022/10/11

## Fixes

- Ensure appium-lib-core is restricted to `5.4.*` while ongoing issues are present in `5.5.*` [408](https://github.com/bugsnag/maze-runner/pull/408)

# 7.2.2 - 2022/10/10

## Fixes

- Ensure `String` patterns behave as expected when calling `Maze.check.match` [407](https://github.com/bugsnag/maze-runner/pull/407)

# 7.2.1 - 2022/10/05

## Fixes

- Fix browser and appium drivers crashing when running without any capabilities [405](https://github.com/bugsnag/maze-runner/pull/405)

# 7.2.0 - 2022/10/04

## Enhancements

- Add step to sort received requests by specific field [402](https://github.com/bugsnag/maze-runner/pull/402)

## Fixes

- Fix local mode, broken in v7 refactor [403](https://github.com/bugsnag/maze-runner/pull/403)

# 7.1.0 - 2022/09/30

## Enhancements

- Improve docs structure [388](https://github.com/bugsnag/maze-runner/pull/388)
- Forward-port v6.23.0 to v6.26.0 to v7 stream [395](https://github.com/bugsnag/maze-runner/pull/395)
- Allow use of legacy Appium/Selenium clients [400](https://github.com/bugsnag/maze-runner/pull/400)

## Fixes

- Remove assert_* methods no longer needed to avoid a breaking change [387](https://github.com/bugsnag/maze-runner/pull/387)
- Fix support for BitBar to work with W3C capabilities [394](https://github.com/bugsnag/maze-runner/pull/394)
- Fix `RequestList` interface to avoid ambiguity [398](https://github.com/bugsnag/maze-runner/pull/398)
- Release BitBar account and stop tunnel on exit [401](https://github.com/bugsnag/maze-runner/pull/401)

## Removals

- Remove support for CrossBrowserTesting [391](https://github.com/bugsnag/maze-runner/pull/391)
- Remove `--resilient` and `--separate-sessions` options [396](https://github.com/bugsnag/maze-runner/pull/396)

## Refactor

- Refactor Appium/Selenium client code into `Maze::Client`
  [390](https://github.com/bugsnag/maze-runner/pull/390)
  [399](https://github.com/bugsnag/maze-runner/pull/399)

# 7.0.0 - 2022/07/29

## Enhancements

- Update appium_lib (v12) and selenium-webdriver (v4), enforcing W3C [364](https://github.com/bugsnag/maze-runner/pull/364)

## Removals

- Remove support for Sauce Labs [376](https://github.com/bugsnag/maze-runner/pull/376)

# 6.26.0 - 2022/09/08

## Enhancements

- Add support for Android 13 and iOS 16 Beta on BrowserStack [393](https://github.com/bugsnag/maze-runner/pull/393)

## Fixes

- Handle nil device list for `--farm=local` [392](https://github.com/bugsnag/maze-runner/pull/392)

# 6.25.0 - 2022/09/05

## Enhancements

- Attach UUIDs to command payloads for better tracking [389](https://github.com/bugsnag/maze-runner/pull/389)

# 6.24.0 - 2022/08/17

## Enhancements

- Add support for Android 13 Beta on BrowserStack [386](https://github.com/bugsnag/maze-runner/pull/386)
  
# 6.23.0 - 2022/07/22

- Update BrowserStack target definitions [383](https://github.com/bugsnag/maze-runner/pull/383)

# 6.22.1 - 2022/07/15

## Fixes

- Display scenario locations in grey [381](https://github.com/bugsnag/maze-runner/pull/381)

# 6.22.0 - 2022/07/12

## Enhancements

- Add driver restart and retry to browser navigation step [377](https://github.com/bugsnag/maze-runner/pull/377)
- Include scenario locations in folding log line [378](https://github.com/bugsnag/maze-runner/pull/378)

# 6.21.0 - 2022/06/29

## Enhancements

- Add support for connecting appium driver to BitBar [282](https://github.com/bugsnag/maze-runner/pull/282)

# 6.20.0 - 2022/06/24

## Enhancements

- Add automatic retries when Selenium driver fails to start [372](https://github.com/bugsnag/maze-runner/pull/372)

# 6.19.1 - 2022/06/17

## Fixes

- Update `Maze::Helper.get_current_platform` to support `browser` [373](https://github.com/bugsnag/maze-runner/pull/373)

# 6.19.0 - 2022/06/14

## Enhancements

- Add support for delivering and saving maze-runner reports [370](https://github.com/bugsnag/maze-runner/pull/370)
- Allow access to pids created by the Runner [371](https://github.com/bugsnag/maze-runner/pull/371)

# 6.18.1 - 2022/05/31

## Fixes

- Update start-driver retry logic to enable device lists [366](https://github.com/bugsnag/maze-runner/pull/366)

# 6.18.0 - 2022/05/30

## Enhancements

- Capture macos screen when scenario fails [369](https://github.com/bugsnag/maze-runner/pull/369)

# 6.17.0 - 2022/05/20

## Enhancements

- Add standalone `upload-app` executable [365](https://github.com/bugsnag/maze-runner/pull/365)
- Add --list-devices option [368](https://github.com/bugsnag/maze-runner/pull/368)


# 6.16.0 - 2022/05/10

## Enhancements

- Allow appium driver start failures to be retried within 60s [359](https://github.com/bugsnag/maze-runner/pull/359)
- Add `Maze.config.captured_invalid_requests` to allow invalid requests to be ignored on specific endpoints [362](https://github.com/bugsnag/maze-runner/pull/362)

## Fixes

- Fix logging of BrowserStack session links [360](https://github.com/bugsnag/maze-runner/pull/360)
- Close Selenium session at end of test run [361](https://github.com/bugsnag/maze-runner/pull/361)

# 6.15.0 - 2022/05/05

## Enhancements

- Allow BrowserStack credentials to be set separately for devices and browsers [358](https://github.com/bugsnag/maze-runner/pull/358)

## Fixes

- Stop BrowserStack tunnel after browser test runs [357](https://github.com/bugsnag/maze-runner/pull/357)

# 6.14.0 - 2022/05/03

## Enhancements

- Add dynamic retries [356](https://github.com/bugsnag/maze-runner/pull/356)

# 6.13.0 - 2022/04/29

## Enhancements

- Add Chrome 40, 42 and iPhone 62 (iOS 9), iPhone 13 (iOS 15.4) support [355](https://github.com/bugsnag/maze-runner/pull/355)
- Allow `--os-version` to be omitted when `--farm=local` [345](https://github.com/bugsnag/maze-runner/pull/345)

## Fixes

- Correct Maze.check.match implementation to allow message to be provided [354](https://github.com/bugsnag/maze-runner/pull/354)

# 6.12.0 - 2022/04/28

## Enhancements

- Add Chrome 30, 32, 34, 36, 38, 40, 42 and Android 4.4, 5.0, 6.0 support [353](https://github.com/bugsnag/maze-runner/pull/353)

# 6.11.1 - 2022/04/21

## Enhancements

- Defaults the read size to 1 MB for the terminating server [352](https://github.com/bugsnag/maze-runner/pull/352)

# 6.11.0 - 2022/04/20

## Enhancements

- Add Maze.driver.page_source [#348](https://github.com/bugsnag/maze-runner/pull/348)
- Add Maze.driver.unlock [#351](https://github.com/bugsnag/maze-runner/pull/351)

## Fixes

- Retry failed BrowserStack app uploads each minute for 10 minutes [#350](https://github.com/bugsnag/maze-runner/pull/350)

# 6.10.0 - 2022/04/12

## Enhancements

- Add method to download device logs from BrowserStack [#344](https://github.com/bugsnag/maze-runner/pull/344)
- Only report to Bugsnag on genuine errors, not test failures [#347](https://github.com/bugsnag/maze-runner/pull/347)
- Add support for CrossBrowserTesting [#342](https://github.com/bugsnag/maze-runner/pull/342)
- Add server for terminating http connections early [#343](https://github.com/bugsnag/maze-runner/pull/343)

## Fixes

- Correct BrowserStack capability to `disableAnimations` [#323](https://github.com/bugsnag/maze-runner/pull/323)

# 6.9.6 - 2022/03/31

## Fixes

- Fix received errors match step [#346](https://github.com/bugsnag/maze-runner/pull/346)

# 6.9.5 - 2022/03/18

## Fixes

- Add retry to BrowserStack app upload [#338](https://github.com/bugsnag/maze-runner/pull/338)

# 6.9.4 - 2022/03/16

## Fixes

- Add the `--color` arg to cucumber a default option [#340](https://github.com/bugsnag/maze-runner/pull/340)

# 6.9.3 - 2022/01/28

## Fixes

- Correct retry pluging to allow `--retry` to have an effect [#337](https://github.com/bugsnag/maze-runner/pull/337)

# 6.9.2 - 2022/01/21

## Fixes

- Make sure valid requests are output with correct JSON formatting [#336](https://github.com/bugsnag/maze-runner/pull/336)

# 6.9.1 - 2022/01/18

## Fixes

- Ensure invalid request logging works correctly in CI mode [#335](https://github.com/bugsnag/maze-runner/pull/335)

# 6.9.0 - 2022/01/12

## Enhancements

- Add `/command` endpoint [#332](https://github.com/bugsnag/maze-runner/pull/332)

# 6.8.0 - 2021/12/21

## Enhancements

- Add `Maze.timers` and Appium operation timing summary [#329](https://github.com/bugsnag/maze-runner/pull/329)

## Fixes

- Set Appium capabilities to speed up iOS App Hang tests locally [#330](https://github.com/bugsnag/maze-runner/pull/330)

## Refactor

- Add `Maze.check` to abstract from underlying assertion implementation 
  [#327](https://github.com/bugsnag/maze-runner/pull/327) 
  [#328](https://github.com/bugsnag/maze-runner/pull/328)
  [#331](https://github.com/bugsnag/maze-runner/pull/331)

# 6.7.0 - 2021/12/15

## Enhancements

- Add step `I send the app to the background` [#326](https://github.com/bugsnag/maze-runner/pull/326)

## Fixes

- Set Appium capabilities for improved performance on Sauce Labs [#325](https://github.com/bugsnag/maze-runner/pull/325)

# 6.6.2 - 2021/12/06

## Fixes

- Fix killing deadlocked Mac fixtures [#320](https://github.com/bugsnag/maze-runner/pull/320)
- Fix support for Sauce Labs [#318](https://github.com/bugsnag/maze-runner/pull/318)
- Ensure `--os` and `--os-version` are provided for Sauce Labs [#319](https://github.com/bugsnag/maze-runner/pull/319)

# 6.6.1 - 2021/12/02

## Fixes

- Bump BrowserStackLocal from 8.0 to 8.4 [#317](https://github.com/bugsnag/maze-runner/pull/317)

# 6.6.0 - 2021/11/23

## Enhancements

- Add Safari 14 and 15 [#316](https://github.com/bugsnag/maze-runner/pull/316)

# 6.5.1 - 2021/11/19

## Fixes

- Make sure device logic isn't run in BrowserStack browser mode [#315](https://github.com/bugsnag/maze-runner/pull/315)

# 6.5.0 - 2021/11/18

## Enhancements

- All `--app` to be specified in a file using `@` prefix [#312](https://github.com/bugsnag/maze-runner/pull/312)
- Allows multiple `--device` options to be specified [#314](https://github.com/bugsnag/maze-runner/pull/314)
- Add automatic reporting to Bugsnag on test failure [#313](https://github.com/bugsnag/maze-runner/pull/313)

# 6.4.0 - 2021/11/08

## Enhancements

- Add automatic retries when appium element cannot be found [#309](https://github.com/bugsnag/maze-runner/pull/309)
- Add feature flag steps [#310](https://github.com/bugsnag/maze-runner/pull/310)

## Fixes

- Use `refresh` when Browser driver can retry scenario [#311](https://github.com/bugsnag/maze-runner/pull/311)

# 6.3.0 - 2021/11/03

## Enhancements

- Add Android 12 and addition Android 7 devices [#308](https://github.com/bugsnag/maze-runner/pull/308)

## Fixes

- Correct command line option for `--enable-retries` [#307](https://github.com/bugsnag/maze-runner/pull/307)

# 6.2.1 - 2021/10/26

## Fixes

- Align Appium versions for iOS devices with latest BrowserStack offering [#305](https://github.com/bugsnag/maze-runner/pull/305)

# 6.2.0 - 2021/10/22

## Enhancements

- Add entry for iOS 15 device on BrowserStack [#304](https://github.com/bugsnag/maze-runner/pull/304)

# 6.1.0 - 2021/10/20

## Enhancements

- Add LLVM to Docker image (and upgrade to Debian 11) [#302](https://github.com/bugsnag/maze-runner/pull/302)

# 6.0.1 - 2021/10/19

## Fixes

- Add further Selenium errors for which a scenario retry can be allowed [#301](https://github.com/bugsnag/maze-runner/pull/301)

# 6.0.0 - 2021/10/18

## Enhancements

- Upgrade to Cucumber 7 [#300](https://github.com/bugsnag/maze-runner/pull/300)
- Adds retry functionality on specific selenium/appium errors or on `@retry` tags [#295](https://github.com/bugsnag/maze-runner/pull/295)

## Fixes

- Improvements to payload step failure messages [#296](https://github.com/bugsnag/maze-runner/pull/296)

# 5.12.0 - 2021/10/02

## Enhancements

- Expose `window_size` on `Maze::Driver::Appium` [#293](https://github.com/bugsnag/maze-runner/pull/293)

# 5.11.0 - 2021/09/21

## Enhancements

- Add reflective servlet to `DocumentServer` [#291](https://github.com/bugsnag/maze-runner/pull/291)

# 5.10.0 - 2021/09/06

## Enhancements

- Add the follow steps [#289](https://github.com/bugsnag/maze-runner/pull/289)
    - `the {word} payload field {string} equals the stored value {string} ignoring case`
    - `the {word} payload field {string} does not equal the stored value {string} ignoring case`

# 5.9.3 - 2021/08/26

## Fixes

- Ensure 'noReset' capability is present when running iOS appium tests locally [#287](https://github.com/bugsnag/maze-runner/pull/287)

# 5.9.2 - 2021/08/23

## Fixes

- Pin Docker images on Debian 10 (Buster) [#286](https://github.com/bugsnag/maze-runner/pull/286)
- Remove blanket rescue for macOS in step `I click the element {string}` [#285](https://github.com/bugsnag/maze-runner/pull/285)

# 5.9.1 - 2021/07/30

## Fixes

- Support running with Ruby 3 [#284](https://github.com/bugsnag/maze-runner/pull/284)

# 5.9.0 - 2021/07/28

## Enhancements

- Add `/sourcemap` and `/react-native-sourcemap` endpoints to `Maze::Server` [#281](https://github.com/bugsnag/maze-runner/pull/281)

# 5.8.0 - 2021/07/26

## Enhancements

- Add Appium driver no-element send_keys method [#278](https://github.com/bugsnag/maze-runner/pull/278)
- Add support for running tests against local browsers [#279](https://github.com/bugsnag/maze-runner/pull/279)

# 5.7.0 - 2021/07/14

## Enhancements

- Add document server (`--document-server-root` and associated options) [#274](https://github.com/bugsnag/maze-runner/pull/274)

## Fixes

- Pin RubyZip to avoid possible breakage from RubyZip 3.0 [#275](https://github.com/bugsnag/maze-runner/pull/275)
- Call after_configuration hooks even if farm is `:none` [#276](https://github.com/bugsnag/maze-runner/pull/276)

## Fixes

- Pin RubyZip to avoid possible breakage under Ruby [#275](https://github.com/bugsnag/maze-runner/pull/275)

# 5.6.0 - 2021/07/09

## Enhancements

- Add `/uploads` endpoint for receiving upload requests [#271](https://github.com/bugsnag/maze-runner/pull/271)
- Add 'the {word} {string} header is null' step [#272](https://github.com/bugsnag/maze-runner/pull/272)

# 5.5.2 - 2021/07/09

## Fixes

- Correct guard for platform-dependent value steps [#270](https://github.com/bugsnag/maze-runner/pull/270)

# 5.5.1 - 2021/07/06

## Fixes

- Only start macOS apps when using Appium [#269](https://github.com/bugsnag/maze-runner/pull/269)

# 5.5.0 - 2021/07/06

## Enhancements

- Add multipart parsing steps usable for any payload types [#261](https://github.com/bugsnag/maze-runner/pull/261)

## Fixes

- Correct logging of received requests [#267](https://github.com/bugsnag/maze-runner/pull/267)
- Allow Windows to be specified as `--os` option [#268](https://github.com/bugsnag/maze-runner/pull/268)

# 5.4.0 - 2021/06/24

## Enhancements

- Add `--file-log` option to write received requests to files [#262](https://github.com/bugsnag/maze-runner/pull/262)
- Add additional BrowserStack Android 10 devices [#264](https://github.com/bugsnag/maze-runner/pull/264)

## Fixes

- Remove short form from all command line options [#263](https://github.com/bugsnag/maze-runner/pull/263)

# 5.3.0 - 2021/06/21

## Enhancements

- Add `--always-log` option [#258](https://github.com/bugsnag/maze-runner/pull/258)

## Fixes

- Add support for macOS running on ARM [#259](https://github.com/bugsnag/maze-runner/pull/259)

# 5.2.0 - 2021/05/19

## Enhancements

- Add Android 9.0 Pixel 2 variant for unity testing [#256](https://github.com/bugsnag/maze-runner/pull/256)

# 5.1.0 - 2021/05/10

## Enhnancements

- Enable locally running appium server to log to a file [#252](https://github.com/bugsnag/maze-runner/pull/252)
  - Log file defaults to `appium_server.log`
  - Can be overwritten using `--appium-logfile` option

## Fixes

- Remove use of unlicensed Boring gem [#251](https://github.com/bugsnag/maze-runner/pull/251)
- Correct wording of failure message for Cucumber step `I should receive no {word}` [#254](https://github.com/bugsnag/maze-runner/pull/254)
- Fix `os` not being present for platform-dependent comparisons outside of device farms [#255](https://github.com/bugsnag/maze-runner/pull/255)

# 5.0.1 - 2021/04/06

## Fixes

- User interface refinements and improved validation [#249](https://github.com/bugsnag/maze-runner/pull/249)

# 5.0.0 - 2021/03/30

## Enhancements

- Integration with Sauce Labs device farm [#246](https://github.com/bugsnag/maze-runner/pull/246)
- Enhances for running Android tests with Appium 1.20.2 [#244](https://github.com/bugsnag/maze-runner/pull/244)
  - Use Appium 1.20.2 for BrowserStack devices where possible 
  - Add `--start-appium` option for running with local devices, defaulting to true
  - Add `Maze::Driver::Appium.set_rotation`

# 4.13.1 - 2021/03/31

## Fixes

- Always log version number [#247](https://github.com/bugsnag/maze-runner/pull/247)

# 4.13.0 - 2021/03/16

## Enhancements

- Add stress-test step asserting a minimum amount of requests received [#239](https://github.com/bugsnag/maze-runner/pull/239)
- Add option to not log received requests on a test failure [#238](https://github.com/bugsnag/maze-runner/pull/238)

# 4.12.1 - 2021/03/04

## Fixes

- Loosen requirements on Lambda responses [#237](https://github.com/bugsnag/maze-runner/pull/237)

# 4.12.0 - 2021/03/04

## Enhancements

- Add click_element_if_present to Appium driver [#236](https://github.com/bugsnag/maze-runner/pull/236)

## Fixes

- Do not set explicit default for mock server bind address [#234](https://github.com/bugsnag/maze-runner/pull/234)

# 4.11.3 - 2021/03/03

## Fixes

- Update endpoint steps and ensure Maze::Network is available by default [#235](https://github.com/bugsnag/maze-runner/pull/235)

# 4.11.2 - 2021/03/03

## Fixes

- Stop BrowserStackLocal binary at end of run without hanging [#233](https://github.com/bugsnag/maze-runner/pull/233)

# 4.11.1 - 2021/03/02

## Fixes
- Stop BrowserStackLocal binary at end of run [#232](https://github.com/bugsnag/maze-runner/pull/232)

# 4.11.0 - 2021/03/02

## Enhancements

- Produce app log for `local` farm test runs [#230](https://github.com/bugsnag/maze-runner/pull/230)
- Add `--bind-address` and `--port` options [#231](https://github.com/bugsnag/maze-runner/pull/231)

# 4.10.1 - 2021/02/16

## Fixes

- Only expand `--app` option when uploading to BrowserStack (complete fix) [#226](https://github.com/bugsnag/maze-runner/pull/226)

# 4.10.0 - 2021/02/16

## Enhancements

- Add steps to delay the response to the next received HTTP request [#224](https://github.com/bugsnag/maze-runner/pull/224)

# 4.9.1 - 2021/02/15

## Fixes

- Only expand `--app` option when uploading to BrowserStack (incomplete fix) [#225](https://github.com/bugsnag/maze-runner/pull/225)

# 4.9.0 - 2021/02/12

## Enhancements

- Add additional CLI and file verification steps [#221](https://github.com/bugsnag/maze-runner/pull/221)
- Add integration with AWS SAM CLI to test Lambda functions [#223](https://github.com/bugsnag/maze-runner/pull/223)

# 4.8.0 - 2021/02/10

## Enhancements

- Add steps to check interactive CLI STDOUT logs using a regex [#220](https://github.com/bugsnag/maze-runner/pull/220)

## Fixes

- Expand file paths for `--app` and `--bs-local` options [#219](https://github.com/bugsnag/maze-runner/pull/219)

# 4.7.0 - 2021/02/08

## Enhancements

- Log BrowserStack link for browser builds [#218](https://github.com/bugsnag/maze-runner/pull/218)

## Fixes

- Correct processing of `/logs` endpoint requests [#216](https://github.com/bugsnag/maze-runner/pull/216)
- Set `disableAnimations` capability on BrowserStack devices [#217](https://github.com/bugsnag/maze-runner/pull/217)

# 4.6.0 - 2021/02/05

## Enhancements

- Add `/logs` endpoint for receiving log messages [#214](https://github.com/bugsnag/maze-runner/pull/214)
- Add `/builds` endpoint for receiving build requests [#213](https://github.com/bugsnag/maze-runner/pull/213)

## Fixes

- Use the standard library rather than `curl` for app uploads and handle error responses [#215](https://github.com/bugsnag/maze-runner/pull/215)

# 4.5.0 - 2021/02/01

## Enhancements

- Add root `/` endpoint for use in connectivity checks [#211](https://github.com/bugsnag/maze-runner/pull/211)

## Fixes

- Remove unnecessary delay between scenarios [#212](https://github.com/bugsnag/maze-runner/pull/212)

# 4.4.0 - 2021/01/28

## Enhancements

- Add in-built appium server control for local testing [#202](https://github.com/bugsnag/maze-runner/pull/202)
- Allow the use of @null and @non-null in platform-dependent assertion tables[#210](https://github.com/bugsnag/maze-runner/pull/210)

# 4.3.1 - 2021/01/26

## Fixes

- Ensure received requests are in order by sent time [#209](https://github.com/bugsnag/maze-runner/pull/209)

# 4.3.0 - 2021/01/25

## Enhancements

- Platform-dependent steps made payload independent [#208](https://github.com/bugsnag/maze-runner/pull/208)

# 4.2.1 - 2021/01/25

## Fixes

- Corrections for Browser automation [#207](https://github.com/bugsnag/maze-runner/pull/207)

# 4.2.0 - 2021/01/22

## Enhancements

- Further Android 4.4 and 5.0 devices added [#206](https://github.com/bugsnag/maze-runner/pull/206)
- Sort received requests by Bugsnag-Sent-At header [#209](https://github.com/bugsnag/maze-runner/pull/209)

# 4.1.0 - 2021/01/21

## Enhancements

- Additional device options added for Android 4.4 and 5.0 [#204](https://github.com/bugsnag/maze-runner/pull/204)

## Fixes

- Logging corrections and improvements [#203](https://github.com/bugsnag/maze-runner/pull/203)

# 4.0.0 - 2021/01/18

## Enhancements

- Mock server and steps updated to receive different request types on separate endpoints [#186](https://github.com/bugsnag/maze-runner/pull/186)

# 3.7.4 - 2021/01/12

## Fixes

- Ensure environment variables cannot leak through --help dialogue
  [#198](https://github.com/bugsnag/maze-runner/pull/198)

# 3.7.3 - 2021/01/08

## Fixes

- Strip ANSI escape codes from interactive CLI output to improve reliability [#197](https://github.com/bugsnag/maze-runner/pull/197)

# 3.7.2 - 2021/01/07

## Fixes

- Fix broken link to BrowserStack dashboard [#196](https://github.com/bugsnag/maze-runner/pull/196)

# 3.7.1 - 2021/01/06

## Fixes

- Only run Docker compose to stop all services if any have been started [#195](https://github.com/bugsnag/maze-runner/pull/195)

# 3.7.0 - 2021/01/05

## Enhancements

- Display version at startup [#191](https://github.com/bugsnag/maze-runner/pull/191)
- Disable BrowserStack network logs by default [#194](https://github.com/bugsnag/maze-runner/pull/194)

# 3.6.1 - 2020/12/16

## Fixes

- Clear request arrays after each scenario instead of beforehand
  [#190](https://github.com/bugsnag/maze-runner/pull/190)

# 3.6.0 - 2020/12/09

## Enhancements

- Add `--capabilities` option
  [#177](https://github.com/bugsnag/maze-runner/pull/177)
- Add support for macOS devices using AppiumForMac
  [#178](https://github.com/bugsnag/maze-runner/pull/178)
- Enforce presence of `Bugsnag-Integrity` based on MazeRunner.config.enforce_bugsnag_integrity
  [#179](https://github.com/bugsnag/maze-runner/pull/179)
  [#180](https://github.com/bugsnag/maze-runner/pull/180)
- Add steps for running interaction shells
  [#185](https://github.com/bugsnag/maze-runner/pull/185)
- Enabled specific configuration options to be set using environment variables.
  [#188](https://github.com/bugsnag/maze-runner/pull/188)


## Fixes

- Fix ordering issue with docker exit code/output
  [#175](https://github.com/bugsnag/maze-runner/pull/175)

# 3.5.1 - 2020/11/17

## Fixes

- Allow timezone offsets in timestamps
  [#174](https://github.com/bugsnag/maze-runner/pull/174)

# 3.5.0 - 2020/11/13

## Enhancements

- Refactor of request steps and additional multipart/form-data steps
  [#163](https://github.com/bugsnag/maze-runner/pull/163)
- Add full range of iOS 11 devices on BrowserStack to test against
  [#166](https://github.com/bugsnag/maze-runner/pull/166)
- Add the Bugsnag-Integrity header to Access-Control-Allow-Headers
  [#167](https://github.com/bugsnag/maze-runner/pull/167)
- Fix always false comparison when checking the simple digest
  [#170](https://github.com/bugsnag/maze-runner/pull/170)

# 3.4.0 - 2020/11/10

## Enhancements

- Add Cucumber steps for checking Bugsnag-Integrity headers, in addition to automatically
  verifying digests on all received requests when the header is present.
  [#159](https://github.com/bugsnag/maze-runner/pull/159)
- Reinstate environment clearing between scenarios
  [#164](https://github.com/bugsnag/maze-runner/pull/164)

## Fixes

- Fix `I clear the element {string}` step.
  [#165](https://github.com/bugsnag/maze-runner/pull/165)

# 3.3.0 - 2020/11/05

## Enhancements

- Make use of ResilientAppiumDriver optional
  [#159](https://github.com/bugsnag/maze-runner/pull/159)

## Fixes

- Fix Appium version for iOS devices to 1.15.0.
  [#161](https://github.com/bugsnag/maze-runner/pull/161)

# 3.2.0 - 2020/11/04

## Enhancements

- Add steps for setting the HTTP status code to be returned to incoming requests
  [#157](https://github.com/bugsnag/maze-runner/pull/157)

## Fixes

- Run docker-compose commands attached rather than detached.
  [#158](https://github.com/bugsnag/maze-runner/pull/158)

# 3.1.0 - 2020/11/02

## Enhancements

- Provide ability to locate elements by accessibility id
  [#151](https://github.com/bugsnag/maze-runner/pull/151)
- Add command line option to set Appium version
  [#152](https://github.com/bugsnag/maze-runner/pull/152)
- New steps for running Docker service with multiline commands and checking values are of certain types.
  [#155](https://github.com/bugsnag/maze-runner/pull/155)

## Fixes

- Explicitly set Appium version for use with BrowserStack devices.
  [#154](https://github.com/bugsnag/maze-runner/pull/154)

# 3.0.3 - 2020/10/26

## Fixes

- Roll in OS version changes from [#145](https://github.com/bugsnag/maze-runner/pull/145) somehow lost by Git/hub
  [#150](https://github.com/bugsnag/maze-runner/pull/150)

# 3.0.2 - 2020/10/21

## Fixes

- Do not clear environment between scenarios (introduced in v2.6.0).
  [#149](https://github.com/bugsnag/maze-runner/pull/149)

# 3.0.1 - 2020/10/20

## Fixes

- Push released Docker images to their own repository to avoid deletion.
  [#146](https://github.com/bugsnag/maze-runner/pull/146)

# 3.0.0 - 2020/10/20

## Enhancements

- BrowserStack specific elements separated from AppAutomateDriver (now simply AppiumDriver),
  providing the ability to use MazeRunner with local devices.
  [#139](https://github.com/bugsnag/maze-runner/pull/139)
- Logging improvements when starting Appium driver (including BrowserStack link)
  [#141](https://github.com/bugsnag/maze-runner/pull/141)

## Fixes

- Resolve logged BrowserStackLocal errors by moving to Ubuntu base image
  [#140](https://github.com/bugsnag/maze-runner/pull/140)

# 2.7.0 - 2020/09/30

## Enhancements

- Allow BrowserStackLocal path to be provided in environment.
  [#137](https://github.com/bugsnag/maze-runner/pull/137)
- Allow URLs to be provided for app location to avoid duplicate uploads.
  [#136](https://github.com/bugsnag/maze-runner/pull/136)
- Addition of ResilientAppiumDriver to catch and restart broken Appium sessions.
  [#134](https://github.com/bugsnag/maze-runner/pull/134)
  [#138](https://github.com/bugsnag/maze-runner/pull/138)
- Added option to start a new Appium session for every scenario.
  [#133](https://github.com/bugsnag/maze-runner/pull/133)

## Fixes

- Correct Android version for device entry Galaxy Tab S3
  [#135](https://github.com/bugsnag/maze-runner/pull/135)

# 2.6.0 - 2020/09/14

## Enhancements

- Table-based assertions on requests, including option to specify
  expected values with Regexps.
  [#131](https://github.com/bugsnag/maze-runner/pull/131)

## Fixes

- Clear environment at start of scenarios
  [#130](https://github.com/bugsnag/maze-runner/pull/130)

# 2.5.0 - 2020/09/11

## Enhancements

- Range of additional Android 6, 8.0 and 8.1 device options provided,
  together with Android 11 and iOS 14.
  [#127](https://github.com/bugsnag/maze-runner/pull/127)
- Ability to run an HTTP/S proxy added
  [#128](https://github.com/bugsnag/maze-runner/pull/128)

## Fixes

- Fix broken Build API step syntax
  [#125](https://github.com/bugsnag/maze-runner/pull/125)
- Fix logging of non-JSON requests
  [#129](https://github.com/bugsnag/maze-runner/pull/129)


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
was employed.  This minor release encapsulates those changes and no further significant
changes to the v1 series is expected (v2 already exists and should be used in preference).

# 1.0.0

Initial release
