Feature: Send a valid trace request

    Scenario: The trace endpoint can identify a valid request
        When I send a "valid" trace request
        Then I wait to receive a trace
