Feature: Reflect payloads are captured

    Scenario: Verify reflect payload bodies can be interrogated
        When I send a "reflect"-type request
        And I wait to receive a reflection
        Then the reflection request method equals "POST"
        And the reflection "some-header" header equals "is-here"
        And the reflection payload field "foo" equals "bar"

    Scenario: Verify reflect queries can be interrogated
        When I send a reflect query request
        And I wait to receive a reflect
        Then the reflect request method equals "GET"
        And the reflect "foo" query parameter equals "1"
        And the reflect "bar" query parameter equals "b"
