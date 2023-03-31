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

    Scenario: Server response code can be set for a single request (503)
        Given I set the HTTP status code for the next request to 503
        When I run the script "features/scripts/send_request.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "503"
        And I discard the oldest error
        And the error payload field "second_code" equals "200"

    Scenario: Server response code can be set for multiple requests
        Given I set the HTTP status code for the next requests to "501,502"
        When I run the script "features/scripts/send_four_requests.rb" using ruby synchronously
        And I wait to receive 4 errors
        Then the error payload field "req" equals "first!"
        And I discard the oldest error
        And the error payload field "first_code" equals "501"
        And I discard the oldest error
        And the error payload field "second_code" equals "502"
        And I discard the oldest error
        And the error payload field "third_code" equals "200"

    Scenario: Server response code can be set for a specific connection type (504)
        Given I set the HTTP status code for the next "OPTIONS" request to 504
        When I run the script "features/scripts/send_verbed_requests.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "first_options_code" equals "504"
        And I discard the oldest error
        And the error payload field "first_options_code" equals "504"
        And the error payload field "first_post_code" equals "200"
        And the error payload field "second_options_code" equals "200"
        And I discard the oldest error
        And the error payload field "second_post_code" equals "200"

    Scenario: Server response code can be set for all subsequent instances of a  specific connection type (505)
        Given I set the HTTP status code for "OPTIONS" requests to 505
        When I run the script "features/scripts/send_verbed_requests.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "first_options_code" equals "505"
        And I discard the oldest error
        And the error payload field "first_options_code" equals "505"
        And the error payload field "first_post_code" equals "200"
        And the error payload field "second_options_code" equals "505"
        And I discard the oldest error
        And the error payload field "second_post_code" equals "200"

    Scenario: Codes without a verb defaults to POST requests
        Given I set the HTTP status code for the next request to 503
        And I run the script "features/scripts/send_verbed_requests.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "first_options_code" equals "200"
        And I discard the oldest error
        And the error payload field "first_options_code" equals "200"
        And the error payload field "first_post_code" equals "503"
        And the error payload field "second_options_code" equals "200"
        And I discard the oldest error
        And the error payload field "second_post_code" equals "200"

    Scenario: A list of codes without a verb defaults to POST requests
        Given I set the HTTP status code for the next requests to "501,502"
        And I run the script "features/scripts/send_verbed_requests.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "first_options_code" equals "200"
        And I discard the oldest error
        And the error payload field "first_options_code" equals "200"
        And the error payload field "first_post_code" equals "501"
        And the error payload field "second_options_code" equals "200"
        And I discard the oldest error
        And the error payload field "second_post_code" equals "502"

    Scenario: Setting blanket codes without a verb defaults to POST requests
        Given I set the HTTP status code to 408
        And I run the script "features/scripts/send_verbed_requests.rb" using ruby synchronously
        And I wait to receive 3 errors
        Then the error payload field "first_options_code" equals "200"
        And I discard the oldest error
        And the error payload field "first_options_code" equals "200"
        And the error payload field "first_post_code" equals "408"
        And the error payload field "second_options_code" equals "200"
        And I discard the oldest error
        And the error payload field "second_post_code" equals "408"
