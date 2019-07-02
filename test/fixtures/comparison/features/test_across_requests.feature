Feature: Comparing elements from one payload to another

    Scenario: Testing two elements match
        When I send a "equal"-type request
        And I send a "equal"-type request
        Then I wait to receive 2 requests
        And the payload field "animals.0" in the current request matches the payload field "animals.0" in the next request

    Scenario: Testing two elements don't match
        When I send a "equal"-type request
        And I send a "equal"-type request
        Then I wait to receive 2 requests
        And the payload field "animals.0" in the current request does not match the payload field "animals.1" in the next request

    Scenario: Testing session's session id matches next event's session id
        When I send a "session"-type request
        And I send a "event-match"-type request
        Then I wait to receive 2 requests
        And the payload has the same session id as the following event payload

    Scenario: Testing event's session id matches next event's session id
        When I send a "event-match"-type request
        And I send a "event-match"-type request
        Then I wait to receive 2 requests
        And the payload has the same session id as the following event payload

    Scenario: Testing session's session id matches next event's session id
        When I send a "session"-type request
        And I send a "event-no-match"-type request
        Then I wait to receive 2 requests
        And the payload does not have the same session id as the following event payload

    Scenario: Testing event's session id matches next event's session id
        When I send a "event-match"-type request
        And I send a "event-no-match"-type request
        Then I wait to receive 2 requests
        And the payload does not have the same session id as the following event payload
