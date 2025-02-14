Feature: Interactive CLI support

  Scenario: Supports a node script
    Given I start a new shell
    When I input "./features/fixtures/node_script" interactively
    And I wait for the shell to output "Starting node script" to stdout
    Then the current stdout line contains "Repeat 5 times "
    When I input "A" interactively
    And I wait for the shell to output "AAAAA" to stdout
    Then the last interactive command exited successfully

  Scenario: Supports regexes
    Given I start a new shell
    When I input "./features/fixtures/node_script" interactively
    And I wait for the shell to output a match for the regex "node script" to stdout
    Then the current stdout line contains "Repeat 5 times "
    When I input "A" interactively
    And I wait for the shell to output a match for the regex "A{5}" to stdout
    Then the last interactive command exited successfully

  Scenario: Allows reading of errors
    Given I start a new shell
    When I input "./features/fixtures/error_script" interactively
    And I wait for the shell to output "Starting error script" to stdout
    Then the current stdout line contains "Input anything to error "
    When I input "A" interactively
    And I wait for the shell to output "Error: Oh no it's all gone wrong" to stderr
    Then the last interactive command exited with an error code
