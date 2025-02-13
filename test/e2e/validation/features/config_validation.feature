Feature: Tests that validation blocks can be provided to the configuration

    Scenario: A scenario passes with no configured validation
        Given I set up the maze-harness console
        And I input "bundle exec maze-runner --port=9349 features/error_payload.feature" interactively
        Then the last interactive command exit code is 0

    Scenario: A scenario passes with pre-configured validation
        Given I set up the maze-harness console
        When I input "VALIDATOR_SCENARIO=pass bundle exec maze-runner --port=9349 features/error_payload.feature" interactively
        Then the last interactive command exit code is 0

    Scenario: A scenario fails with pre-configured validation
        Given I set up the maze-harness console
        When I input "VALIDATOR_SCENARIO=fail bundle exec maze-runner --port=9349 features/error_payload.feature" interactively
        Then the last interactive command exit code is 1

    Scenario: A scenario passes if the validation block is empty
        Given I set up the maze-harness console
        When I input "VALIDATOR_SCENARIO=empty bundle exec maze-runner --port=9349 features/error_payload.feature" interactively
        Then the last interactive command exit code is 0

    Scenario: A scenario fails if the block makes it fail
        Given I set up the maze-harness console
        When I input "VALIDATOR_SCENARIO=custom_fail bundle exec maze-runner --port=9349 features/error_payload.feature" interactively
        Then the last interactive command exit code is 1

    Scenario: A scenario fails if an error occurs in the block
        Given I set up the maze-harness console
        When I input "VALIDATOR_SCENARIO=error bundle exec maze-runner --port=9349 features/error_payload.feature" interactively
        Then the last interactive command exit code is 1

    Scenario: The default validation runs if not overwritten
        Given I set up the maze-harness console
        When I input "bundle exec maze-runner --port=9349 features/trace_payload.features" interactively
        Then the last interactive command exit code is 1

    Scenario: Configured validation overrides default validation
        Given I set up the maze-harness console
        When I input "VALIDATOR_SCENARIO=trace bundle exec maze-runner --port=9349 features/trace_payload.features" interactively
        Then the last interactive command exit code is 0
