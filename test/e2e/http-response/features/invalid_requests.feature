Feature: Tests with invalid requests

  Scenario: Ignore invalid errors
    When I ignore invalid errors
    And I run the script "features/scripts/send_invalid_error.rb" using ruby synchronously
    And I wait to receive an error
