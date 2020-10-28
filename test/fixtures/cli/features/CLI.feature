Feature: Interactive CLI support

  Scenario: Supports a node script
    Given I start a new shell
    When I input "./features/fixtures/node_script" interactively
    And I wait for 2 seconds
    Then the shell has output "Starting node script" to stdout
    And the current stdout line is "Repeat 5 times "
    When I input "A" interactively
    And I wait for 1 seconds
    Then the shell has output "Repeat 5 times AAAAA" to stdout

  Scenario: Allows reading of errors
    Given I start a new shell
    When I input "./features/fixtures/error_script" interactively
    And I wait for 2 seconds
    Then the shell has output "Starting error script" to stdout
    And the current stdout line is "Input anything to error "
    When I input "A" interactively
    And I wait for 1 seconds
    Then the shell exited with an error code
    And the shell has output "Error: Oh no it's all gone wrong" to stderr
