Feature: Sends a payload to the trace endpoint

    Scenario: An trace payload is sent
        When I send a request to the "traces" endpoint
        Then I wait to receive a trace
