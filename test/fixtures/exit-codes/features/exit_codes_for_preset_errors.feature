Feature: Test exit codes are specific to certain errors

Scenario: A "Maze::Error::AppiumElementNotFoundError" results in exit code 11
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 --fail-fast features/throw_a_maze_appiumelementnotfounderror.feature" interactively
    Then the last interactive command exit code is 11

Scenario: A "Selenium::WebDriver::Error::TimeoutError" results in exit code 13
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 --fail-fast features/throw_a_webdriver_timeouterror.feature" interactively
    Then the last interactive command exit code is 13

Scenario: A "Selenium::WebDriver::Error::UnknownError" results in exit code 10
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 --fail-fast features/throw_a_webdriver_unknownerror.feature" interactively
    Then the last interactive command exit code is 10

Scenario: A non-specific error doesn't modify the exit code
    Given I set up the maze-harness console
    And I input "bundle exec maze-runner --port=9349 --fail-fast features/throw_a_runtimeerror.feature" interactively
    # If maze-runner exits due to `fail-fast` being present the default exit code is 2, not 1
    Then the last interactive command exit code is 2
