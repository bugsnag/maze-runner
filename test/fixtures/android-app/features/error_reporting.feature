Feature: Android support

Scenario: Test handled Android Error
    When I set environment variable "BUGSNAG_API_KEY" to "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And I set environment variable "EVENT_TYPE" to "HandledException"
    And I launch the app
    And I set environment variable "EVENT_TYPE" to "none"
    And I launch the app
    Then I should receive a request
    And the request is a valid for the error reporting API
    And the "Bugsnag-API-Key" header equals "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And the payload field "notifier.name" equals "Android Bugsnag Notifier"
    And the payload field "events" is an array with 1 element
    And the exception "errorClass" equals "RuntimeException"
    And the exception "message" equals "The cake was rotten"
    And the "machoFile" of stack frame 0 ends with "/CoreFoundation"
