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
  And the event "exceptions.0.errorClass" matches the correct platform value:
    | android | java.lang.Exception |
  And the event "exceptions.0.message" matches the correct platform value:
    | android | HandledException!   |
  And the event "exceptions.0.message" matches the correct platform value:
    | android | skip |
  # Verifies the environment variable change works
  And the payload field "apiKey" equals the environment variable "BUGSNAG_API_KEY"
