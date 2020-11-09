Feature: Tests that hooks are called appropriately

  Background:
    Given I set environment variable "BACKGROUND" to "ALWAYS_SET"

  Scenario: Set variable
    Then the environment variable "TEST_KEY" equals "TEST_VALUE"
    And the environment variable "BACKGROUND" equals "ALWAYS_SET"

  Scenario: Do not set variable
    Then the environment variable "TEST_KEY" is null
    And the environment variable "BACKGROUND" equals "ALWAYS_SET"
