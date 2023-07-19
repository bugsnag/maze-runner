Feature: Testing support for span receipt and interrogation

    Scenario: An exact amount of spans
        When I send a span request with 3 spans
        Then I wait to receive 3 spans

    Scenario: An exact amount of spans across payloads
        When I send a span request with 1 span
        And I send a span request with 2 spans
        Then I wait to receive 3 spans

    Scenario: A minimum amount of spans
        When I send a span request with 3 spans
        Then I wait to receive at least 1 span

    Scenario: A minimum amount of spans across payloads
        When I send a span request with 1 span
        And I send a span request with 4 spans
        Then I wait to receive at least 3 spans

    Scenario: A minimum amount of spans, with the minimum
        When I send a span request with 1 spans
        Then I wait to receive at least 1 span

    Scenario: Spans within a certain range
        When I send a span request with 2 spans
        Then I wait to receive between 1 and 3 spans

    Scenario: Spans within a certain range across payloads
        When I send a span request with 2 spans
        And I send a span request with 3 spans
        Then I wait to receive between 4 and 8 spans

    Scenario: Spans within a certain range, with the minimum
        When I send a span request with 1 span
        Then I wait to receive between 1 and 3 spans

    Scenario: Spans within a certain range, with the minimum
        When I send a span request with 3 spans
        Then I wait to receive between 1 and 3 spans

    Scenario: Span counts outside the expected amount fail
       Given I set up the maze-harness console
       And I input "bundle exec maze-runner --port=9349 features/span_count_failure.feature" interactively
       Then the last interactive command exit code is 1

    Scenario: Span counts under a minimum fail
       Given I set up the maze-harness console
       And I input "bundle exec maze-runner --port=9349 features/span_minimum.feature" interactively
       Then the last interactive command exit code is 1

    Scenario: Span counts over a maximum fail
       Given I set up the maze-harness console
       And I input "bundle exec maze-runner --port=9349 features/span_maximum.feature" interactively
       Then the last interactive command exit code is 1
