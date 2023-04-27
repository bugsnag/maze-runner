Feature: Browser smoke tests

  Scenario: IP based
    When I navigate to the URL "http://172.217.16.238"

  Scenario: Receiving responses from URLs
    When I navigate to the test URL "/test.html"
    Then I wait to receive an error
    And the error payload field "test" equals "browser"
    And Maze Runner reports the current platform as "browser"

  Scenario: Maze Runner
    When I navigate to Maze Runner
    And I wait for 5 seconds
