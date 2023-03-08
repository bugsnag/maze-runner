Feature: Testing support on traces endpoint

    Scenario: The traces endpoint can accept json payloads
        When I send a "trace"-type request
        Then I wait to receive a trace
        And The HTTP response header "Bugsnag-Sampling-Probability" equals "1"
        And the trace payload field "resourceSpans.0.resource.attributes.0.key" equals "device.id"
        And the trace payload field "resourceSpans.0.resource.attributes.0.value.stringValue" equals "cd5c48566a5ba0b8597dca328c392e1a7f98ce86"

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
        When I enforce checking of the Bugsnag-Integrity header
        And I run the script "features/scripts/send_gzip.sh" synchronously
        And I wait to receive a trace
        Then the trace Bugsnag-Integrity header is valid
        And the trace payload field "resourceSpans.0.resource.attributes.0.key" equals "device.id"
        And the trace payload field "resourceSpans.0.resource.attributes.0.value.stringValue" equals "cd5c48566a5ba0b8597dca328c392e1a7f98ce86"

    Scenario: The trace endpoint can identify a valid request
        Given I set up the maze-harness console
        And I input "bundle exec maze-runner --port=9349 features/passing_schema.feature" interactively
        Then the last interactive command exit code is 0

    Scenario: The trace endpoint can identify an invalid request
       Given I set up the maze-harness console
       And I input "bundle exec maze-runner --port=9349 features/failing_schema.feature" interactively
       Then the last interactive command exit code is 1
