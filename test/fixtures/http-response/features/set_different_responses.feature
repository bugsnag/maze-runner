Feature: Setting different response codes

    Scenario: Default response codes (200) are present
        When I run the script "features/scripts/send_request.sh" synchronously
        And I wait to receive 3 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "200"
        And I discard the oldest error
        And the error payload field "second_code" equals "200"

    Scenario: Server response code can be set for all subsequent requests (400)
        Given I set the HTTP status code to 400
        When I run the script "features/scripts/send_request.sh" synchronously
        And I wait to receive 3 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "400"
        And I discard the oldest error
        And the error payload field "second_code" equals "400"

    Scenario: Server response code can be set a single request (503)
        Given I set the HTTP status code for the next request to 503
        When I run the script "features/scripts/send_request.sh" synchronously
        And I wait to receive 3 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "503"
        And I discard the oldest error
        And the error payload field "second_code" equals "200"
