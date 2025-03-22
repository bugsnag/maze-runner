Feature: Exercise the Appium Manager APIs

  Scenario: App Manager operations
    When The app state is "running_in_foreground"
    And I close the app
    Then The app state is "not_running"
    And I launch the app
    Then The app state is "running_in_foreground"
    And I terminate the app
    Then The app state is "not_running"
    And I activate the app
    Then The app state is "running_in_foreground"

  Scenario: Device Manager operations
    When I unlock the device
    And I get the device logs
    And I set the device rotation to "landscape"
    And I wait for 2 seconds
    And I set the device rotation to "portrait"
    And I log the device info
    And I press the back button

  Scenario: UI Manager operations
    When the element "clearUserData" is present
    And I click the element "clearUserData"
    And I click the element "clearUserData" if present
