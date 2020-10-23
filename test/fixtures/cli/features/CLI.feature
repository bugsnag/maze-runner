Feature: Interactive CLI support

  Scenario: Supports a node script
    Given I start a new terminal
    And I wait for 2 seconds
    When I input "./features/fixtures/node_script" interactively
    And I wait for 2 seconds
    Then the terminal has output "Starting node script"
    And the terminal is outputting "Repeat 5 times "
    When I input "A" interactively
    And I wait for 2 seconds
    Then the terminal has output "Repeat 5 times AAAAA"

  Scenario: Allows reading of errors
    Given I start a new terminal
    And I wait for 2 seconds
    When I input "./features/fixtures/error_script" interactively
    And I wait for 2 seconds
    Then the terminal has output "Starting error script"
    And the terminal is outputting "Input anything to error "
    When I input "A" interactively
    And I wait for 2 seconds
    Then the terminal exited with an error code
    And the terminal has the error message "Oh no it's all gone wrong"
