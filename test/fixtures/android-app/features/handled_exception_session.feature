Feature: Android support

Scenario: Test handled Android Exception with Session
    When I start Android emulator "newnexus"
    And I install the "com.bugsnag.android.mazerunner" app from "app/build/outputs/apk/release/app-release.apk"
    And I set environment variable "BUGSNAG_API_KEY" to "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And I set environment variable "EVENT_TYPE" to "HandledExceptionSession"
    And I start the "com.bugsnag.android.mazerunner" app using the "com.bugsnag.android.mazerunner.MainActivity" activity
    Then I should receive a request
    And the request is a valid for the error reporting API
    And the "Bugsnag-API-Key" header equals "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And the payload field "notifier.name" equals "Android Bugsnag Notifier"
    And the payload field "events" is an array with 1 element
    And the exception "errorClass" equals "java.lang.RuntimeException"
    And the exception "message" equals "HandledExceptionSession"
