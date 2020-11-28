Feature: Checks on value types

  Scenario: Checks on values of different types
    When I send a "values"-type request
    Then I wait to receive 1 request
    And the payload field "values.uuid" is a UUID
    And the payload field "values.number" is a number
    And the payload field "values.integer" is an integer
    And the payload field "values.date" is a date
