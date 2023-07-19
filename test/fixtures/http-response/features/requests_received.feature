Feature: Testing support for payload counts

    Scenario: An exact amount of payloads
        When I send 2 requests
        Then I wait to receive 2 errors

    Scenario: A minimum amount of payloads
        When I send 4 requests
        Then I have received at least 2 errors

    Scenario: A minimum amount of payloads, with the minimum
        When I send 2 requests
        Then I have received at least 2 errors

    Scenario: Payload counts within a range
        When I send 2 requests
        Then I wait to receive between 1 and 3 errors

    Scenario: Payload counts within a range, with the minimum
        When I send 1 request
        Then I wait to receive between 1 and 3 errors

    Scenario: Payload counts within a range, with the maximum
        When I send 3 requests
        Then I wait to receive between 1 and 3 errors

    Scenario: Payloads outside the expected amount fail
       Given I set up the maze-harness console
       And I input "bundle exec maze-runner --port=9349 features/expected_requests_failure.feature" interactively
       Then the last interactive command exit code is 1

    Scenario: Payloads under a minimum fail
       Given I set up the maze-harness console
       And I input "bundle exec maze-runner --port=9349 features/minimum_requests_failure.feature" interactively
       Then the last interactive command exit code is 1

    Scenario: Payloads over a maximum fail
       Given I set up the maze-harness console
       And I input "bundle exec maze-runner --port=9349 features/maximum_requests_failure.feature" interactively
       Then the last interactive command exit code is 1