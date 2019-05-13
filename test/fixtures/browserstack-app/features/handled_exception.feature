Feature: Android support

Scenario: Test Handled Android Exception
  Given the element "trigger_error" is present
  When I click the element "trigger_error"
  Then I wait to receive a request
  And the exception "errorClass" equals "java.lang.Exception"
  And the exception "message" equals "HandledException!"
