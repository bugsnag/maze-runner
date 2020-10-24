# frozen_string_literal: true

# MazeRunner configuration
class Configuration
  # Whether each scenario should have its own Appium session
  attr_accessor :appium_session_isolation

  # Device farm to be used, one of:
  # :bs (BrowserStack)
  # :local (Using Appium Server with a local device)
  # :none (Cucumber-driven testing with no devices)
  attr_accessor :farm

  # Location of the BrowserStackLocal binary (if used)
  attr_accessor :bs_local

  # Farm username
  attr_accessor :username

  # Farm access key
  attr_accessor :access_key

  # Apple Team Id
  attr_accessor :apple_team_id

  # BrowserStack device type
  attr_accessor :bs_device

  # OS version
  attr_accessor :os_version

  # Device id for running on local iOS devices
  attr_accessor :device_id

  # URL of the Appium server
  attr_accessor :appium_server_url

  # Appium capabilities
  attr_accessor :capabilities

  # File path or URL of the app (IPA or APK) that tests will be run against
  attr_accessor :app_location
end
