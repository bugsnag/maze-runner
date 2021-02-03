Feature: Build endpoint tests
    Scenario: Build verification steps work correctly
        When I send a "build"-type request
        And I wait to receive a build
        Then the build is valid for the Build API

    Scenario: Android Mapping API verification works correctly
        When I send a "build"-type request
        And I wait to receive a build
        Then the build is valid for the Android Mapping API

    Scenario: General purpose steps work with build payloads
        When I send a "build"-type request
        And I wait to receive a build
        Then the build payload field "apiKey" equals the environment variable "BUGSNAG_API_KEY"
        And the build payload field "appVersion" equals "SEBT£"
        And the build payload field "genesis" is true
        And the build payload field "yes" is false
        And the build payload field "wakeman" is null
        And the build payload field "proguard" is not null
        And the build payload field "albums" equals 15
        And the build payload field "live_albums" is greater than 5
        And the build payload field "live_albums" is less than 7
