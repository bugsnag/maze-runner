Feature: Expected requests

    Scenario: Have too many incoming requests
        When I send 3 requests
        Then I wait to receive 2 errors
