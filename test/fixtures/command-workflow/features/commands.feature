Feature: Tests the command servlet works as expected

  Scenario: Commands are received in order
    Given I add a command with message "first"
    And I add a command with message "second"
    Then I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "first"
    And the error payload field "command_response.uuid" is stored as the value "uuid"
    And the error payload field "command_response.run_uuid" is stored as the value "run_uuid"
    And I discard the oldest error
    Then I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "second"
    And the error payload field "command_response.uuid" does not equal the stored value "uuid"
    And the error payload field "command_response.run_uuid" equals the stored value "run_uuid"

  Scenario: Idempotent commands are sent correctly
    Given I generate a series of commands with sequential UUIDs
    Then I run the "bounce_idempotent_command" test script with UUID "1"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "second"
    And the error payload field "command_response.uuid" equals "2"
    Then I run the "bounce_idempotent_command" test script with UUID "2"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "third"
    And the error payload field "command_response.uuid" equals "3"
    Then I run the "bounce_idempotent_command" test script with UUID "1"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "second"
    And the error payload field "command_response.uuid" equals "2"

  Scenario: A noop is sent when no commands are added
    When I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "No commands queued"
    And the error payload field "command_response.action" equals "noop"
    And the error payload field "command_status" equals 200

  Scenario: An noop is sent when commands run out
    Given I add a command with message "first"
    And I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "first"
    And I discard the oldest error
    Then I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "No commands queued"
    And the error payload field "command_response.action" equals "noop"
    And the error payload field "command_status" equals 200

  Scenario: An error is sent when the idempotent UUID is incorrect
    Given I generate a series of commands with sequential UUIDs
    Then I run the "bounce_idempotent_command" test script with UUID "8"
    And I wait to receive an error
    Then the error payload field "command_response" equals "Request invalid - there is no command with a UUID of 8 to follow on from"
    And the error payload field "command_status" equals 400

  Scenario: The next command is sent when the previous idempotent UUID is used
    Given I generate a series of commands with sequential UUIDs
    Then I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "first"
    And the error payload field "command_response.uuid" equals "1"
    And I discard the oldest error
    Then I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "second"
    And the error payload field "command_response.uuid" equals "2"
    And I discard the oldest error
    Then I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "third"
    And the error payload field "command_response.uuid" equals "3"
    And I discard the oldest error
    Then I run the "bounce_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "fourth"
    And the error payload field "command_response.uuid" equals "4"
    And I discard the oldest error

    Then I add a command with message "fifth"
    And I run the "bounce_idempotent_command" test script with UUID "4"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "fifth"
