Feature: Testing gzip support on traces endpoint

    Scenario: The traces endpoint can accept json payloads
        When I send a "trace"-type request
        Then I wait to receive a trace
        And the trace payload field "trace-value-1" equals "one"
        And the trace payload field "trace-value-2" equals "two"

    Scenario: The traces endpoint can accept gzipped streams
        When I run the script "features/scripts/send_gzip.sh" synchronously
        And I wait to receive a trace
        And the trace payload field "hello" equals "world"
        And the trace payload field "array" is a non-empty array
        And The HTTP response header "Bugsnag-Sampling-Probability" equals "1"
