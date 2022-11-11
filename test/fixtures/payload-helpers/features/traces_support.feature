Feature: Testing gzip support on traces endpoint

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


    Scenario: The traces endpoint can accept gzipped streams
        When I run the script "features/scripts/send_gzip.sh" synchronously
        And I wait to receive a trace
        Then the trace payload field "hello" equals "world"
        And the trace payload field "array" is a non-empty array
