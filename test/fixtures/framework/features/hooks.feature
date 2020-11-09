Feature: Tests that hooks are called appropriately

  Scenario: Set variable
    Then the environment variable "TEST_KEY" equals "TEST_VALUE"

  Scenario: Do not set variable
    Then the environment variable "TEST_KEY" is null
