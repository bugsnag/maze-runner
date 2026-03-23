Feature: Unordered requests can be tested using a table

    Scenario: Testing payloads pass regardless of order
        When I make a "ordered 1"-type POST request
        And I make a "ordered 2"-type POST request
        And I wait to receive 2 errors
        Then the requests match the following:
          | foo | bar |
          | a   | b   |
          | b   | a   |
        And the requests match the following:
          | foo | bar |
          | b   | a   |
          | a   | b   |

    Scenario: Testing errors regardless of order
        When I make a "error 1"-type POST request
        And I make a "error 2"-type POST request
        And I wait to receive 2 errors
        Then the received errors match:
          | null?     | count |
          | @not_null | one   |
          | null      | two   |
        And the received errors match:
          | null?     | count |
          | null      | two   |
          | @not_null | one   |