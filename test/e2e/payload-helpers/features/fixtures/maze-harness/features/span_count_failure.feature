Feature: Send too few requests

    Scenario: Span counts outside the expected amount fail
        When I send a span request with 3 spans
        Then I wait to receive 2 spans
