Feature: Comparing JSON payloads to fixture files

    Scenario: The request body matches the template text exactly
        When I send a "equal"-type request
        Then I wait to receive an error
        And the error payload body matches the JSON fixture in "features/fixtures/exact_match.json"
        And the error payload body matches the JSON fixture in "features/fixtures/fuzzy_match.json"

    Scenario: The request body matches the template when ignoring fields
        When I send an "ignore"-type request
        Then I wait to receive an error
        And the error payload body matches the JSON fixture in "features/fixtures/ignore_apple.json"
        And the error payload body does not match the JSON fixture in "features/fixtures/exact_match.json"
        And the error payload body does not match the JSON fixture in "features/fixtures/fuzzy_match.json"

    Scenario: The request body fuzzy matches the template
        When I send an "fuzzy match"-type request
        Then I wait to receive an error
        And the error payload body does not match the JSON fixture in "features/fixtures/exact_match.json"
        And the error payload body matches the JSON fixture in "features/fixtures/fuzzy_match.json"

    Scenario: A subset of the request body matches a template
        When I send an "subset"-type request
        Then I wait to receive an error
        And the error payload field "items.0.subset" matches the JSON fixture in "features/fixtures/exact_match.json"
        And the error payload field "items.0.subset" matches the JSON fixture in "features/fixtures/fuzzy_match.json"

    Scenario: The request body matches the template using "NUMBER" wildcards
        When I send a "numerics"-type request
        And I wait to receive an error
        Then the error payload body matches the JSON fixture in "features/fixtures/numerics.json"

    Scenario: The request body does not match the template using "NUMBER" wildcards
        When I send an "ignore"-type request
        And I wait to receive an error
        Then the error payload body does not match the JSON fixture in "features/fixtures/numerics.json"

    Scenario Outline: The request body does not match the template
        When I send an "<request_type>"-type request
        Then I wait to receive an error
        And the error payload body does not match the JSON fixture in "features/fixtures/exact_match.json"
        And the error payload body does not match the JSON fixture in "features/fixtures/fuzzy_match.json"

        Examples:
        | request_type                    |
        | extra object in array           |
        | missing key                     |
        | different object in array       |
        | different fixnum in object      |
        | missing nested object key       |
        | different object for nested key |
        | fuzzy mismatch                  |
