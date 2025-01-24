Feature: Exercise the App Manager API

  Scenario: App Manager operations
    When The app state is "running_in_foreground"
    And I close the app
    Then The app state is "not_running"
    And I launch the app
    Then The app state is "running_in_foreground"
