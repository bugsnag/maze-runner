Feature: Comparing elements from one payload to another

    Scenario: Testing two elements match
        When I make a "equal"-type POST request
        And I make a "equal"-type POST request
        Then I wait to receive 2 errors
        And I wait to receive at least 1 error
        And the error payload field "animals.0" is stored as the value "animal_zero"
        And I discard the oldest error
        And the error payload field "animals.0" equals the stored value "animal_zero"

    Scenario: Testing two elements don't match
        When I make a "equal"-type POST request
        And I make a "equal"-type POST request
        Then I wait to receive 2 errors
        And the error payload field "animals.0" is stored as the value "animal_zero"
        And I discard the oldest error
        And the error payload field "animals.1" does not equal the stored value "animal_zero"

    Scenario: Testing two elements match, ignoring case
        When I make a "caseless equal"-type POST request
        And I make a "equal"-type POST request
        Then I wait to receive 2 errors
        And the error payload field "animals.0" is stored as the value "animal_zero"
        And I discard the oldest error
        And the error payload field "animals.0" equals the stored value "animal_zero" ignoring case

    Scenario: Testing two elements don't match, ignoring case
        When I make a "caseless equal"-type POST request
        And I make a "equal"-type POST request
        Then I wait to receive 2 errors
        And the error payload field "animals.0" is stored as the value "animal_zero"
        And I discard the oldest error
        And the error payload field "animals.1" does not equal the stored value "animal_zero" ignoring case
