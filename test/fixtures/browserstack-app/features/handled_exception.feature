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
