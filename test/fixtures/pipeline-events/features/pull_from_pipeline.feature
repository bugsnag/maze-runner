Feature: We can pull processed requests from Bugsnag Development

    Scenario: We can pull a processed event from the pipeline
        Given I send a request to the server
        Then I wait to receive an event
        And the last event is available via the data access api
