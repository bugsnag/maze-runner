Feature: Using the different varieties of proxy server

    Scenario: Testing basic HTTP proxy
        When I start an http proxy
        And I run the script "features/scripts/http.sh"
        Then I wait to receive a request
        And the payload body matches the JSON fixture in "features/fixtures/payload.json"
        And the proxy handled a request for "localhost:9339"

    Scenario: Testing basic HTTPS proxy
        When I start an https proxy
        And I run the script "features/scripts/https.sh"
        Then I wait to receive a request
        And the payload body matches the JSON fixture in "features/fixtures/payload.json"
        And the proxy handled a request for "localhost:9339"
