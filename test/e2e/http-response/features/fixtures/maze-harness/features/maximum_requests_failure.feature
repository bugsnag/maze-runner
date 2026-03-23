Feature: Maximum requests

    Scenario: Have more than the maximum
        When I send 4 requests
        Then I wait to receive between 1 and 3 spans
