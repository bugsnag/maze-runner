Feature: Error config requests and responses

  Scenario: Basic handling if error-config request
    When I make an "android error-config"-type GET request
    And I wait for 1 error configs to be requested
    Then the error config request "Bugsnag-Api-Key" header equals "12312312312312312312312312312312"

    And the error config request "version" query parameter equals "1.2.3"
    And the error config request "versionCode" query parameter equals "123"
    And the error config request "releaseStage" query parameter equals "production"
    And the error config request "osVersion" query parameter equals "11"
