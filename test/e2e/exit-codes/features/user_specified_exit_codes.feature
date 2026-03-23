Feature: Test user-specified exit codes

Scenario: A user-specified exit code outputs correctly
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 --fail-fast features/set_exit_code.feature" interactively
    Then the last interactive command exit code is 43

Scenario: A user-specified exit code overrides an error-related exit code
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 --fail-fast features/set_exit_then_error.feature" interactively
    Then the last interactive command exit code is 44
