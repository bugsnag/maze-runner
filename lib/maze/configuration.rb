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
    # Server configuration
    #

    # Mock server bind address
    attr_accessor :bind_address

    # Mock server port
    attr_accessor :port

    #
    # Document server configuration
    #

    # Document server root
    attr_accessor :document_server_root

    # Document server bind address
    attr_accessor :document_server_bind_address

    # Document server port
    attr_accessor :document_server_port

    #
    # Common configuration
    #

    # Time in seconds to wait in the `I should receive no requests` step
    attr_accessor :receive_no_requests_wait

    # Maximum time in seconds to wait in the `I wait to receive {int} error(s)/session(s)/build(s)` steps
    attr_accessor :receive_requests_wait

    # Whether presence of the Bugsnag-Integrity header should be enforced
    attr_accessor :enforce_bugsnag_integrity

    # Whether retries should be allowed
    attr_accessor :enable_retries

    #
    # General appium configuration
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

    #
    # Device farm specific configuration
    #

    # Location of the BrowserStackLocal binary (if used)
    attr_accessor :bs_local

    # Location of the Sauce Connect binary (if used)
    attr_accessor :sl_local

    # Farm username
    attr_accessor :username

    # Farm access key
    attr_accessor :access_key

    # Test device type
    attr_accessor :device

    # Test browser type
    attr_accessor :browser

    # Appium version to use
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

    # Whether an appium server should be started
    attr_accessor :start_appium

    # The location of the appium server logfile
    attr_accessor :appium_logfile

    #
    # Logging configuration
    #

    # Write received requests to disk for all scenarios
    attr_accessor :file_log

    # Console logging of received requests for a test failure
    attr_accessor :log_requests

    # Always log all received requests to the console at the end of a scenario
    attr_accessor :always_log
  end
end
