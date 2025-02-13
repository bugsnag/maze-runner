Feature: Set an exit code then exit

Scenario: Set the exit code
    Given I set the exit code to 43
    Then I have received at least 3 errors
