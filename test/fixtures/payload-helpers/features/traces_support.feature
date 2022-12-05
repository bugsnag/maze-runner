Feature: Testing support on traces endpoint

    Scenario: The traces endpoint can accept json payloads
        When I send a "trace"-type request
        Then I wait to receive a trace
        And the trace payload field "trace-value-1" equals "one"
        And the trace payload field "trace-value-2" equals "two"
        And The HTTP response header "Bugsnag-Sampling-Probability" equals "1"

        # Sampling probability can be set for all subsequent trace requests
        Then I discard the oldest trace
        And I set the sampling probability to "0.5"
        And I send a "trace"-type request
        And I wait to receive a trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" equals "0.5"
        And I discard the oldest trace

        And I send a "trace"-type request
        And I wait to receive a trace
        And I discard the oldest trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" equals "0.5"

        # Sampling probability can be set for just the next trace request
        And I set the sampling probability for the next trace to "0.7"
        And I send a "trace"-type request
        And I wait to receive a trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" equals "0.7"
        And I discard the oldest trace

        And I send a "trace"-type request
        And I wait to receive a trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" equals "1"
        And I discard the oldest trace

        # Sampling probability can be set for a series of trace requests, returning to the default
        Then I set the sampling probability for the next traces to "0.7,null,0.2"
        And I send a "trace"-type request
        And I wait to receive a trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" equals "0.7"
        And I discard the oldest trace

        And I send a "trace"-type request
        And I wait to receive a trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" is null
        And I discard the oldest trace

        And I send a "trace"-type request
        And I wait to receive a trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" equals "0.2"
        And I discard the oldest trace

        And I send a "trace"-type request
        And I wait to receive a trace
        Then The HTTP response header "Bugsnag-Sampling-Probability" equals "1"

    Scenario: The traces endpoint can accept gzipped streams
        When I run the script "features/scripts/send_gzip.sh" synchronously
        And I wait to receive a trace
        And the trace payload field "hello" equals "world"
        And the trace payload field "array" is a non-empty array

    Scenario: The trace endpoint can identify a valid request
        Given I set up the maze-harness console
        And I input "bundle exec maze-runner --port=9349 features/passing_schema.feature" interactively
        Then the last interactive command exit code is 0

    # Currently the trace endpoint doesn't opperate with a proper schema, so this isn't a possible test
    #Scenario: The trace endpoint can identify an invalid request
    #    Given I set up the maze-harness console
    #    And I input "bundle exec maze-runner --port=9349 features/failing_schema.feature" interactively
    #    Then the last interactive command exit code is 1
