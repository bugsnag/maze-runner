Feature: Handled Errors and Exceptions

  Background:
    Given I clear all persistent data

  Scenario: Override errorClass and message from a notifyError() callback, customize report
    When I run "HandledErrorOverrideScenario"
    And I wait to receive an error
    Then the error is valid for the error reporting API
