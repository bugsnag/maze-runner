Feature: Browser smoke tests

Scenario: Receiving responses from URLs
  When I navigate to the test URL "/test.html"
  Then I wait to receive an error
  And the error payload field "test" equals "browser"
  And Maze Runner reports the current platform as "browser"
