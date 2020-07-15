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
  # Verify string comparison
  And the event "exceptions.0.errorClass" matches the string platform value:
    | android | java.lang.Exception |
  # Verify boolean comparisons
  And the event "metaData.test.boolean_true" matches the boolean platform value:
    | android | true |
  And the event "metaData.test.boolean_false" matches the boolean platform value:
    | android | false |
  # Verify numeric comparisons
  And the event "metaData.test.float" matches the numeric platform value:
    | android | 1.55 |
  And the event "metaData.test.integer" matches the numeric platform value:
    | android | 2 |
  # Verify the skips
  And the event "metaData.test.integer" matches the string platform value:
    | android | @skip |
  And the event "metaData.test.integer" matches the boolean platform value:
    | android | @skip |
  And the event "exceptions.0.errorClass" matches the numeric platform value:
    | android | @skip |
  # Verifies the environment variable change works
  And the payload field "apiKey" equals the environment variable "BUGSNAG_API_KEY"
