Feature: Tests the dedicated idempotent command servlet works as expected

  Scenario: Idempotent commands are served correctly from the dedicated endpoint
    Given I generate a series of commands with sequential UUIDs
    Then I run the "bounce_dedicated_idempotent_command" test script with UUID "1"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "second"
    And the error payload field "command_response.uuid" equals "2"
    And I discard the oldest error
    Then I run the "bounce_dedicated_idempotent_command" test script with UUID "2"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "third"
    And the error payload field "command_response.uuid" equals "3"
    And I discard the oldest error
    Then I run the "bounce_dedicated_idempotent_command" test script with UUID "1"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "second"
    And the error payload field "command_response.uuid" equals "2"

  Scenario: A noop is served from the dedicated endpoint when no commands are added
    When I run the "bounce_dedicated_idempotent_command" test script
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "No commands queued"
    And the error payload field "command_response.action" equals "noop"
    And the error payload field "command_status" equals 200

  Scenario: The first command is served when no UUID is provided
    Given I generate a series of commands with sequential UUIDs
    And I run the "bounce_dedicated_idempotent_command" test script with UUID ""
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "first"

  Scenario: An noop is served from the dedicated endpoint when there is no next command
    Given I generate a series of commands with sequential UUIDs
    And I run the "bounce_dedicated_idempotent_command" test script with UUID "4"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "No commands queued"
    And the error payload field "command_response.action" equals "noop"
    And the error payload field "command_status" equals 200

  Scenario: A command to reset the UUID is served when the idempotent UUID is incorrect
    Given I generate a series of commands with sequential UUIDs
    Then I run the "bounce_dedicated_idempotent_command" test script with UUID "8"
    And I wait to receive an error
    Then the error payload field "command_response.message" equals "The UUID given was unknown - client must reset its last known UUID"
    Then the error payload field "command_response.action" equals "reset_uuid"
    And the error payload field "command_status" equals 200
