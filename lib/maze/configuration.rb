# frozen_string_literal: true

module Maze
  # MazeRunner configuration
  class Configuration

    # Set default values
    def initialize
      self.receive_no_requests_wait = 30
      self.receive_requests_wait = 30
      self.enforce_bugsnag_integrity = true
    end

    #
    # Common configuration
    #

    # Whether each scenario should have its own Appium session
    attr_accessor :appium_session_isolation

    # Element locator strategy, :id or :accessibility_id
    attr_accessor :locator

    # Appium capabilities
    attr_accessor :capabilities

    # Appium capabilities provided via the CL
    attr_accessor :capabilities_option

    # The app that tests will be run against.  Could be one of:
    # - a local file path
    # - a BrowserStack url for a previously uploaded app (bs://...)
    # - on macOS, the name of an installed or previously executed application
    attr_accessor :app

    # Whether the ResilientAppium driver should be used (only applicable when using Appium in the first place)
    attr_accessor :resilient

    # Device farm to be used, one of:
    # :bs (BrowserStack)
    # :local (Using Appium Server with a local device)
    # :none (Cucumber-driven testing with no devices)
    attr_accessor :farm

    # Time in seconds to wait in the `I should receive no requests` step
    attr_accessor :receive_no_requests_wait

    # Maximum time in seconds to wait in the `I wait to receive {int} error(s)/session(s)` steps
    attr_accessor :receive_requests_wait

    # Whether presence of the Bugsnag-Integrity header should be enforced
    attr_accessor :enforce_bugsnag_integrity

    #
    # BrowserStack specific configuration
    #

    # Location of the BrowserStackLocal binary (if used)
    attr_accessor :bs_local

    # Farm username
    attr_accessor :username

    # Farm access key
    attr_accessor :access_key

    # BrowserStack device type
    attr_accessor :bs_device

    # BrowserStack browser type
    attr_accessor :bs_browser

    # Appium version to use on BrowserStack
    attr_accessor :appium_version

    #
    # Local testing specific configuration
    #

    # Apple Team Id
    attr_accessor :apple_team_id

    # OS
    attr_accessor :os

    # OS version
    attr_accessor :os_version

    # Device id for running on local iOS devices
    attr_accessor :device_id

    # URL of the Appium server
    attr_accessor :appium_server_url
  end
end
