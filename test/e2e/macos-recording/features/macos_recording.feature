Feature: macOS browser recording

  Scenario: Open browser, navigate to bugsnag.com, wait, and close
    When I navigate to the URL "https://www.bugsnag.com"
    Then I wait for 5 seconds
