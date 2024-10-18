Feature: We can create a project, send an event to the new project and verify
    that the event is available via the data access api

    Scenario: We can create a project, send an event to the new project and verify
        Given I create a new project "My Project" with type "ruby"
        When I send a request to the server
        Then I wait to receive an error
        And the last event is available via the data access api
        And the pipeline event payload field "exceptions.0.message" equals "This is an error"
