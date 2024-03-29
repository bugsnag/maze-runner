Feature: Unordered requests can be tested using a table

    Scenario: Testing payloads pass regardless of order
        When I send a "ordered 1"-type request
        And I send a "ordered 2"-type request
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
        When I send a "error 1"-type request
        And I send a "error 2"-type request
        And I wait to receive 2 errors
        Then the received errors match:
          | null?     | count |
          | @not_null | one   |
          | null      | two   |
        And the received errors match:
          | null?     | count |
          | null      | two   |
          | @not_null | one   |