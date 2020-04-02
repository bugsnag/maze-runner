Feature: Tests steps that target request details

    Scenario: The HTTP version can be asserted against
        Given I send an HTTP 1.1 request
        Then I should receive a request
        And the HTTP version is "1.1"

    Scenario: The HTTP version can be asserted against on different requests
        Given I send an HTTP 1.1 request
        And I send an HTTP 1.0 request
        Then I should receive 2 requests
        And the HTTP version is "1.1" for request 0
        And the HTTP version is "1.0" for request 1