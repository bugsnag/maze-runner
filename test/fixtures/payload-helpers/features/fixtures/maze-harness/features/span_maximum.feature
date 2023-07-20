Feature: Send too many requests

    Scenario: Span counts over the maximum fail
        When I send a span request with 4 span
        Then I wait to receive between 2 and 3 spans
