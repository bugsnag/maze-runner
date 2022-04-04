# 6.10.0 - TBD

## Enhancements

- Add method to download device logs from BrowserStack [#344](https://github.com/bugsnag/maze-runner/pull/344)
- Only report to Bugsnag on genuine errors, not test failures [#347](https://github.com/bugsnag/maze-runner/pull/347)
- Add support for CrossBrowserTesting [#342](https://github.com/bugsnag/maze-runner/pull/342)

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
- Sort received requests by Bugsnag-Sent-At header [#207](https://github.com/bugsnag/maze-runner/pull/207)

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
