Feature: Using the different varieties of proxy server

    Scenario: Basic HTTP proxy
        When I start an http proxy
        And I run the script "features/scripts/http.sh"
        Then I wait to receive an error
        And the error payload body matches the JSON fixture in "features/fixtures/payload.json"
        And the proxy handled a request for "localhost:9339"

    Scenario: Authenticated HTTP proxy with creds
        When I start an authenticated http proxy
        And I run the script "features/scripts/http_with_creds.sh"
        Then I wait to receive an error
        And the error payload body matches the JSON fixture in "features/fixtures/payload.json"
        And the proxy handled a request for "localhost:9339"

    Scenario: Authenticated HTTP proxy without creds
        When I start an authenticated http proxy
        And I run the script "features/scripts/http.sh"
        Then I wait for 5 seconds
        And I should receive no errors

    Scenario: Basic HTTPS proxy use
        When I start an https proxy
        And I run the script "features/scripts/https.sh"
        Then I wait to receive an error
        And the error payload body matches the JSON fixture in "features/fixtures/payload.json"
        And the proxy handled a request for "localhost:9339"

    Scenario: Authenticated HTTPS proxy with creds
        When I start an authenticated https proxy
        And I run the script "features/scripts/https_with_creds.sh"
        Then I wait to receive an error
        And the error payload body matches the JSON fixture in "features/fixtures/payload.json"
        And the proxy handled a request for "localhost:9339"

    Scenario: Authenticated HTTPS proxy without creds
        When I start an authenticated https proxy
        And I run the script "features/scripts/https.sh"
        Then I wait for 5 seconds
        And I should receive no errors
