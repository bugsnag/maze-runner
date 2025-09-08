Feature: Checks on log requests

  Scenario: Checks on values of different types
    When I make an "info-log"-type POST request
    And I make an "error-log"-type POST request
    And I wait to receive 2 logs
    Then the "INFO" level log message matches the regex "^Today is \d{4}\-\d{2}\-\d{2}$"
    And I discard the oldest log
    Then the "ERROR" level log message equals "The world is no longer on pause"
