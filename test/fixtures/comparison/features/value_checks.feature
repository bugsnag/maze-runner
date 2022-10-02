Feature: Checks on value types

  Scenario: Checks on values of different types
    When I send a "values"-type request
    And I wait to receive 1 error

    Then the error payload field "values.uuid" is a UUID
    And the error payload field "values.number" is a number
    And the error payload field "values.integer" is an integer
    And the error payload field "values.date" is a date

  Scenario: Verify that multiple requests can be sorted by field
    When I send a "ordered 1"-type request
    And I wait to receive 1 error
    And I send a "ordered 2"-type request
    # Now 2 errors in total
    And I wait to receive 2 errors

    Then the error payload field "bar" equals "b"
    And I sort the errors by the payload field "bar"

    Then the error payload field "bar" equals "a"
    And I discard the oldest error

    Then the error payload field "bar" equals "b"
