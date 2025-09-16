Feature: Error config requests and responses

  Scenario: Basic handling of error-config request
    When I prepare an error config with:
      | type     | name           | value                               |
      | header   | Cache-Control  | max-age=604800                      |
      | property | body           | @features/support/error_config.json |
      | property | status         | 200                                 |
    And I request an "android" type error config and store the response
    And I wait for 1 error configs to be requested

    Then the error config request "Bugsnag-Api-Key" header equals "12312312312312312312312312312312"
    And the error config request "version" query parameter equals "1.2.3"
    And the error config request "versionCode" query parameter equals "123"
    And the error config request "releaseStage" query parameter equals "production"
    And the error config request "osVersion" query parameter equals "11"

    And the stored error config status code equals "200"
    And the stored error config "Cache-Control" header equals "max-age=604800"
    And the stored error config "Etag" header equals "43ec7d2b971daba752e9546da4e1dca8094107e0"
