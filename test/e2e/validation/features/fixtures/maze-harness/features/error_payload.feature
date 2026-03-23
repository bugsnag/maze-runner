Feature: Sends a payload to the error endpoint

    Scenario: An error payload is sent
        When I send a request to the "notify" endpoint
        Then I wait to receive an error
