Feature: Breadcrumb helper steps

    Scenario: The payload contains a breadcrumb with a type and name
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event has a "process" breadcrumb named "foo"
        And the event has 3 breadcrumbs

    Scenario: The payload contains a breadcrumb with a type and message
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event has a "process" breadcrumb with message "Foobar"
        And the event has 3 breadcrumbs

    Scenario: The payload does not contain a type of breadcrumb
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event does not have a "request" breadcrumb
        And the event has 3 breadcrumbs

    Scenario: The payload does not contain a type of breadcrumb with a particular message
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event does not have a "process" breadcrumb with message "Barfoo"
        And the event has 3 breadcrumbs

    Scenario: The payload has a breadcrumb which matches a JSON fixture
        When I send a "breadcrumbs"-type request
        Then I wait to receive an error
        And the event contains a breadcrumb matching the JSON fixture in "features/fixtures/breadcrumb_match.json"
        And the event has 3 breadcrumbs

    Scenario: The payload has no breadcrumbs
        Given I send a "handled"-type request
        When I wait to receive an error
        Then the event has no breadcrumbs
        Then the event has 0 breadcrumbs

    Scenario: The payload has 1 breadcrumb
        Given I send a "breadcrumb"-type request
        When I wait to receive an error
        Then the event has a "process" breadcrumb named "foo"
        And the event has 1 breadcrumb
