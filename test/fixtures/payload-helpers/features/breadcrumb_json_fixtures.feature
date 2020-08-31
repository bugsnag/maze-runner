Feature: Breadcrumb helper steps

    Scenario: The payload contains a breadcrumb with a type and name
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event has a "process" breadcrumb named "foo"

    Scenario: The payload contains a breadcrumb with a type and message
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event has a "process" breadcrumb with message "Foobar"

    Scenario: The payload does not contain a type of breadcrumb
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event does not have a "request" breadcrumb

    Scenario: The payload has a breadcrumb which matches a JSON fixture
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event contains a breadcrumb matching the JSON fixture in "features/fixtures/breadcrumb_match.json"
