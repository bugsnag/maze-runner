Feature: Test exit codes aren't overwritten with --fail-fast missing

Scenario: An exit code linked to an error isn't present when --fail-fast is missing
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 features/throw_a_maze_appiumelementnotfounderror.feature" interactively
    Then the last interactive command exit code is 1

Scenario: A user-set exit code isn't present when --fail-fast is missing
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 features/set_exit_code.feature" interactively
    Then the last interactive command exit code is 1

Scenario: Mark as failed
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 features/mark_as_failed.feature" interactively
    Then the last interactive command exit code is 1
    And the shell has output a match for the regex "You told me to" to stdout
