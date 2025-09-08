Feature: Checks on value types

  Scenario: Checks on values of different types
    When I make a "values"-type POST request
    And I wait to receive 1 error
    And I have received at least 1 error

    Then the error payload field "values.uuid" is a UUID
    And the error payload field "values.number" is a number
    And the error payload field "values.integer" is an integer
    And the error payload field "values.date" is a date

  Scenario: Verify that multiple requests can be sorted by field
    When I make a "ordered 1"-type POST request
    And I wait to receive 1 error
    And I make a "ordered 2"-type POST request
    # Now 2 errors in total
    And I wait to receive 2 errors

    Then the error payload field "bar" equals "b"
    And I sort the errors by the payload field "bar"

    Then the error payload field "bar" equals "a"
    And I discard the oldest error

    Then the error payload field "bar" equals "b"
