# @!group Android steps

# Starts an Android emulator available within the local environment
#
# @step_input emulator [String] The name of the emulator to start
When("I start Android emulator {string}") do |emulator|
  steps %Q{
    When I set environment variable "ANDROID_EMULATOR" to "#{emulator}"
    And I run the script "launch-android-emulator.sh"
    And I run the script "await-android-emulator.sh" synchronously
  }
end

# Synchronously clears the data for the test application
# Requires an ADB connection
When("I clear the Android app data") do
  step('I run the script "clear-android-app-data.sh" synchronously')
end

# Force stops the test application
# Requires an ADB connection
When("I force stop the Android app") do
  step('I run the script "force-stop-android-app.sh" synchronously')
end

# Installs a given bundle from an APK onto a device
# Requires an ADB connection
#
# @step_input bundle [String] The bundle to be installed
# @step_input filepath [String] The path to the application's .apk
When("I install the {string} Android app from {string}") do |bundle, filepath|
  steps %Q{
    When I set environment variable "APP_BUNDLE" to "#{bundle}"
    And I set environment variable "APK_PATH" to "#{filepath}"
    And I run the script "install-android-app.sh" synchronously
  }
end

# Starts a specific activity for a given app
# Requires an ADB connection
#
# @step_input app [String] The application name
# @step_input activity [String] The activity to start
When("I start the {string} Android app using the {string} activity") do |app, activity|
  steps %Q{
    When I set environment variable "APP_BUNDLE" to "#{app}"
    When I set environment variable "APP_ACTIVITY" to "#{activity}"
    And I run the script "launch-android-app.sh" synchronously
    And I wait for 4 seconds
  }
end
