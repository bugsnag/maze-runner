Feature: Terminating requests early

    Scenario: Terminating server can be started and respond to a request
        Given I start the terminating server
        When I run the script "features/scripts/terminating_request.rb" using ruby synchronously
        And I wait to receive an error
        And the terminating server has received 1 requests
