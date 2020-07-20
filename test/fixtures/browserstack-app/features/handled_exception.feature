Feature: Android support

Scenario: Test Handled Android Exception
  Given the element "trigger_error" is present
  When I click the element "trigger_error"
  Then I wait to receive a request
  And the request is valid for the error reporting API version "4.0" for the "Android Bugsnag Notifier" notifier
  And the exception "errorClass" equals "java.lang.Exception"
  And the exception "message" equals "HandledException!"
  # Verifies the environment variable change works
  And the payload field "apiKey" equals the environment variable "BUGSNAG_API_KEY"

Scenario: Verify "equals the correct platform value" step
  Given the element "trigger_error" is present within 30 seconds
  When I click the element "trigger_error"
  Then I wait to receive a request
  And the request is valid for the error reporting API version "4.0" for the "Android Bugsnag Notifier" notifier
  # Verify string comparisons
  And the event "exceptions.0.errorClass" equals the platform-dependent string:
    | android | java.lang.Exception |
  And the payload field "events.0.exceptions.0.errorClass" equals the platform-dependent string:
    | android | java.lang.Exception |
  # Verify boolean comparisons
  And the payload field "events.0.metaData.test.boolean_true" equals the platform-dependent boolean:
    | android | true |
  And the event "metaData.test.boolean_true" equals the platform-dependent boolean:
    | android | true |
  And the payload field "events.0.metaData.test.boolean_false" equals the platform-dependent boolean:
    | android | false |
  And the event "metaData.test.boolean_false" equals the platform-dependent boolean:
    | android | false |
  # Verify numeric comparisons
  And the payload field "events.0.metaData.test.float" equals the platform-dependent numeric:
    | android | 1.55 |
  And the payload field "events.0.metaData.test.integer" equals the platform-dependent numeric:
    | android | 2 |
  And the event "metaData.test.float" equals the platform-dependent numeric:
    | android | 1.55 |
  And the event "metaData.test.integer" equals the platform-dependent numeric:
    | android | 2 |
  # Verify the skips
  And the event "metaData.test.integer" equals the platform-dependent string:
    | android | @skip |
  And the event "metaData.test.integer" equals the platform-dependent boolean:
    | android | @skip |
  And the event "exceptions.0.errorClass" equals the platform-dependent numeric:
    | android | @skip |
  And the payload field "events.0.metaData.test.integer" equals the platform-dependent string:
    | android | @skip |
  And the payload field "events.0.metaData.test.integer" equals the platform-dependent boolean:
    | android | @skip |
  And the payload field "events.0.exceptions.0.errorClass" equals the platform-dependent numeric:
    | android | @skip |
  # Verifies the environment variable change works
  And the payload field "apiKey" equals the environment variable "BUGSNAG_API_KEY"
