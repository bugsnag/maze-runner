Feature: Tests that hooks are called appropriately

  Background:
    Given I set environment variable "BACKGROUND" to "ALWAYS_SET"

  Scenario: Set variable
    Then the Runner.environment entry for "TEST_KEY" equals "TEST_VALUE"
    And the Runner.environment entry for "BACKGROUND" equals "ALWAYS_SET"
    And the Runner.environment entry for "AFTER_CONFIG" equals "FIRST_SCENARIO_ONLY"

  Scenario: Do not set variable
    Then the Runner.environment entry for "TEST_KEY" is null
    And the Runner.environment entry for "BACKGROUND" equals "ALWAYS_SET"
    And the Runner.environment entry for "AFTER_CONFIG" is null
