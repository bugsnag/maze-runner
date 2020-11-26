Feature: Interactive CLI support

  Scenario: Supports a node script
    Given I start a new shell
    When I input "./features/fixtures/node_script" interactively
    And I wait for the shell to output "Starting node script" to stdout
    Then the current stdout line is "Repeat 5 times "
    When I input "A" interactively
    And I wait for the shell to output "Repeat 5 times AAAAA" to stdout
    And I wait for the current shell to exit
    Then the shell exited successfully

  Scenario: Allows reading of errors
    Given I start a new shell
    When I input "./features/fixtures/error_script" interactively
    And I wait for the shell to output "Starting error script" to stdout
    Then the current stdout line is "Input anything to error "
    When I input "A" interactively
    And I wait for the current shell to exit
    Then the shell exited with an error code
    And the shell has output "Error: Oh no it's all gone wrong" to stderr
