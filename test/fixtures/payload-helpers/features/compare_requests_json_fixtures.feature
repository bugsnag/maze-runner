Feature: Testing helper methods respond correctly

    Scenario: The request body matches an expected error payload
        When I send a "payload"-type request
        Then I wait to receive a request
        And the request is valid for the error reporting API version "4.0" for the "Maze-runner" notifier

    Scenario: The request body matches an expected session payload
        When I send a "session"-type request
        Then I wait to receive a request
        And the request is valid for the session reporting API version "1.0" for the "Maze-runner" notifier

    Scenario: The request body is correct for an unhandled payload
        When I send a "unhandled"-type request
        Then I wait to receive a request
        And event 0 is unhandled

    Scenario: The request body is correct for an unhandled payload with session data
        When I send an "unhandled session"-type request
        Then I wait to receive a request
        And event 0 is unhandled

    Scenario: The request body is correct for an unhandled payload with a custom severity
        When I send an "unhandled severity"-type request
        Then I wait to receive a request
        And event 0 is unhandled with the severity "info"

    Scenario: The request body is correct for a handled payload
        When I send a "handled"-type request
        Then I wait to receive a request
        And event 0 is handled

    Scenario: The request body is correct for a handled payload with session data
        When I send a "handled session"-type request
        Then I wait to receive a request
        And event 0 is handled

    Scenario: The request body is correct for a handled payload with a custom severity
        When I send a "handled severity"-type request
        Then I wait to receive a request
        And event 0 is handled with the severity "error"

    Scenario: The request body is correct for a payload with mixed events
        When I send a "handled then unhandled"-type request
        Then I wait to receive a request
        And event 0 is handled
        And event 1 is unhandled