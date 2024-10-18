Feature: We can pull processed requests from Bugsnag Development

    Scenario: We can pull a processed event from the pipeline
        When I send a request to the server
        Then I wait to receive an error
        And the last event is available via the data access api
        And the pipeline event payload field "exceptions.0.message" equals "This is an error"