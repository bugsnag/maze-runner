Feature: Send too few requests

    Scenario: Span counts under the minimum fail
        When I send a span request with 1 span
        Then I wait to receive at least 2 spans
