Feature: Checks on value types

  Scenario: Checks on values of different types
    When I send a "values"-type request
    Then I wait to receive 1 error
    And the error payload field "values.uuid" is a UUID
    And the error payload field "values.number" is a number
    And the error payload field "values.integer" is an integer
    And the error payload field "values.date" is a date
