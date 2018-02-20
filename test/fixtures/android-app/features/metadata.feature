Feature: Android support

Scenario: Metadata Report
    When I run "MetaDataScenario" with the defaults
    Then I should receive a request
    And the request is a valid for the error reporting API
    And the "Bugsnag-API-Key" header equals "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And the exception "message" equals "MetaDataScenario"
    And the event "metaData.Custom.foo" equals "Hello World!"
