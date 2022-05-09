Feature: Tests retry functionality

  @retry
  Scenario: Retry annotation
    When I fail on the first attempt

  Scenario: Dynamic retry
    When I let the scenario retry
    And I fail on the first attempt
