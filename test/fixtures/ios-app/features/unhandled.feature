Feature: Uncaught NSExceptions are captured by Bugsnag

  Background:
    Given I clear all persistent data

  Scenario: Throw a NSException
    When I run "ObjCExceptionScenario" and relaunch the app
    And I configure Bugsnag for "ObjCExceptionScenario"
    And I wait to receive an error
    Then the error is valid for the error reporting API
    And the exception "message" equals "An uncaught exception! SCREAM."
    And the exception "errorClass" equals "NSGenericException"
    And the "method" of stack frame 0 equals the platform-dependent string:
      | ios   | <redacted>            |
      | macos | __exceptionPreprocess |
    And the "method" of stack frame 1 equals "objc_exception_throw"
    And the "method" of stack frame 2 equals "-[ObjCExceptionScenario run]"
    And the error payload field "events.0.device.time" is a date
    And the event "severity" equals "error"
    And the event "unhandled" is true
    And the event "severityReason.type" equals "unhandledException"