Feature: Test exit codes aren't overwritten with --fail-fast missing

Scenario: An exit code linked to an error isn't present when --fail-fast is missing
    Given I set up the testception wrapper
    And I input "bundle exec maze-runner --port=9349 features/throw_a_maze_appiumelementnotfounderror.feature" interactively
    Then the last interactive command exit code is 1

Scenario: A user-set exit code isn't present when --fail-fast is missing
    Given I set up the testception wrapper
    And I input "bundle exec maze-runner --port=9349 features/set_exit_code.feature" interactively
    Then the last interactive command exit code is 1
