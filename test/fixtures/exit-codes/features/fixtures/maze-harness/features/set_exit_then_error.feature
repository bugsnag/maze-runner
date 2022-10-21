Feature: Set an exit code then error

Scenario: Set the exit code and error
    Given I set the exit code to 44
    And I raise "Maze::Error::AppiumElementNotFoundError"
