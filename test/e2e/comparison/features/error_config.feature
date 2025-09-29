Feature: Error config requests and responses

  Scenario: Basic handling of error-config request
    When I prepare an error config with:
      | type     | name           | value                               |
      | header   | Cache-Control  | max-age=222                         |
      | property | body           | @features/support/error_config.json |
      | property | status         | 500                                 |
    And I request an "android" type error config and store the response
    And I wait for 1 error config to be requested

    Then the error config request "Bugsnag-Api-Key" header equals "12312312312312312312312312312312"
    And the error config request "version" query parameter equals "1.2.3"
    And the error config request "versionCode" query parameter equals "123"
    And the error config request "releaseStage" query parameter equals "production"
    And the error config request "osVersion" query parameter equals "11"

    And the stored error config status code equals "500"
    And the stored error config body matches the contents of "features/support/error_config.json"
    And the stored error config "Cache-Control" header equals "max-age=222"
    And the stored error config "Etag" header equals "43ec7d2b971daba752e9546da4e1dca8094107e0"

  # This scenario ensures that error config state is not leaked between scenarios
  Scenario: Ensure error-config request lists are cleared between scenarios
    When I prepare an error config with:
      | type     | name           | value                               |
      | header   | Cache-Control  | max-age=333                         |
      | property | body           | @features/support/error_config.json |
      | property | status         | 400                                 |
    And I request an "ios" type error config and store the response
    And I wait for 1 error config to be requested

    Then the error config request "Bugsnag-Api-Key" header equals "12312312312312312312312312312312"
    And the error config request "version" query parameter equals "3.2.1"
    And the error config request "bundleVersion" query parameter equals "321"
    And the error config request "releaseStage" query parameter equals "development"
    And the error config request "osVersion" query parameter equals "15"

    And the stored error config status code equals "400"
    And the stored error config body matches the contents of "features/support/error_config.json"
    And the stored error config "Cache-Control" header equals "max-age=333"
    And the stored error config "Etag" header equals "43ec7d2b971daba752e9546da4e1dca8094107e0"
