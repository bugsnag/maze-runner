Feature: Send an invalid trace request

    Scenario: The trace endpoint can identify an invalid request
        When I send a "invalid" trace request
        Then I wait to receive a trace
