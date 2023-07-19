Feature: Minimum requests

    Scenario: Have less than the minimum
        When I send 2 requests
        Then I have received at least 3 requests
