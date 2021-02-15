Feature: Setting different response codes

    Scenario: Default response codes (200) are present
        When I set the response delay for the next request to 3100 milliseconds
        And I run the script "features/scripts/send_request.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "200"
        And the error payload field "first_time" is greater than 3000
        And I discard the oldest error
        And the error payload field "second_code" equals "200"
        And the error payload field "second_time" is less than 3000

    Scenario: Server behaviour can be set for all subsequent requests (400)
        Given I set the HTTP status code to 400
        And I set the response delay to 3100 milliseconds
        When I run the script "features/scripts/send_request.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "400"
        And the error payload field "first_time" is greater than 3000
        And I discard the oldest error
        And the error payload field "second_code" equals "400"
        And the error payload field "second_time" is greater than 3000

    Scenario: Server response code can be set a single request (503)
        Given I set the HTTP status code for the next request to 503
        When I run the script "features/scripts/send_request.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "503"
        And I discard the oldest error
        And the error payload field "second_code" equals "200"
