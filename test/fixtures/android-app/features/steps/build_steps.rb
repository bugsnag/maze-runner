# Possibly generic steps to upstream
When("I start Android emulator {string}") do |emulator|
  steps %Q{
    When I set environment variable "EMULATOR" to "#{emulator}"
    And I run the script "features/scripts/launch-emulator.sh"
    And I run the script "features/scripts/await-emulator.sh" synchronously
  }
end
When("I install the {string} app from {string}") do |bundle, filepath|
  steps %Q{
    When I set environment variable "APP_BUNDLE" to "#{bundle}"
    And I set environment variable "APK_PATH" to "#{filepath}"
    And I run the script "features/scripts/install-app.sh" synchronously
  }
end
When("I start the {string} app using the {string} activity") do |app, activity|
  steps %Q{
    When I set environment variable "APP_BUNDLE" to "#{app}"
    When I set environment variable "APP_ACTIVITY" to "#{activity}"
    And I run the script "features/scripts/launch-app.sh" synchronously
    And I wait for 4 seconds
  }
end
When("I wait for the {string} app to close") do |app|
  step('I run the script "features/scripts/await-app-close.sh" synchronously')
end

# Project-specific steps
When("I build the app") do
  steps %Q{
    When I run the script "features/scripts/build-app.sh"
    And I wait for 8 seconds
  }
end
When("I launch the app") do
  steps %Q{
    When I run the script "features/scripts/launch-app.sh"
    And I wait for 5 seconds
  }
end
When("I configure the app to trigger {string}") do |event_type|
end
