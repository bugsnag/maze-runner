# frozen_string_literal: true

module Maze
  # MazeRunner configuration
  class Configuration

    # Set default values
    def initialize
      self.receive_no_requests_wait = 30
      self.receive_requests_wait = 30
      self.receive_requests_slow_threshold = 10
      self.enforce_bugsnag_integrity = true
      self.captured_invalid_requests = Set[:errors, :sessions, :builds, :uploads, :sourcemaps]
      self.android_app_files_directory = nil
      self.span_timestamp_validation = true
      self.unmanaged_traces_mode = false
      self.client_mode_validation = true
      @legacy_driver = false
    end

    #
    # Server configuration
    #

    # Whether the mock server should use https
    attr_accessor :https

    # Mock server bind address
    attr_accessor :bind_address

    # Mock server port
    attr_accessor :port

    # Terminating server bind port
    attr_accessor :null_port

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

    # Time after which requests are deemed to be slow to be received and a warning is logged for
    attr_accessor :receive_requests_slow_threshold

    # Whether presence of the Bugsnag-Integrity header should be enforced
    attr_accessor :enforce_bugsnag_integrity

    # Whether retries should be allowed
    attr_accessor :enable_retries

    # Enables bugsnag reporting
    attr_accessor :enable_bugsnag

    # The server endpoints for which invalid requests should be captured and cause tests to fail
    attr_accessor :captured_invalid_requests

    # API key to use when repeating requests to Bugsnag
    attr_accessor :bugsnag_repeater_api_key

    # API key to use when repeating requests to InsightHub
    attr_accessor :hub_repeater_api_key

    # Enables awareness of a public IP address on Buildkite with the Elastic CI Stack for AWS.
    attr_accessor :aws_public_ip

    # Whether timestamp validation should be performed on spans
    attr_accessor :span_timestamp_validation

    # Enables unmanaged trace mode.
    attr_accessor :unmanaged_traces_mode

    # Custom validators to use for a given endpoint
    attr_reader :custom_validators

    # Consumes a block that will be triggered when a request is received for a specific endpoint
    # This will prevent any existing default validation from triggering.
    #
    # @param endpoint [String] The endpoint to validate
    # @param validator [Proc] The block to run when a request is received
    def add_validator(endpoint, &validator)
      @custom_validators ||= {}
      @custom_validators[endpoint] = validator
    end

    # Whether default validation should be skipped for a given endpoint
    attr_reader :skipped_validators

    # Sets whether to skip default validation for a given endpoint
    #
    # @param endpoint [String] The endpoint to skip default validation for
    def skip_default_validation(endpoint)
      @skipped_validators ||= {}
      @skipped_validators[endpoint] = true
    end

    # Sets whether validation should be run in client mode
    attr_accessor :client_mode_validation

    #
    # General appium configuration
    #

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

    # Device farm to be used, one of:
    # :bs (BrowserStack)
    # :local (Using Appium Server with a local device)
    # :none (Cucumber-driven testing with no devices)
    attr_accessor :farm

    # Whether the device farm secure tunnel should be started
    attr_accessor :start_tunnel

    # Folder to push app files to on Android
    attr_accessor :android_app_files_directory

    #
    # Device farm specific configuration
    #

    # Location of the SmartBear binary (if used)
    attr_accessor :sb_local

    # Location of the BrowserStackLocal binary (if used)
    attr_accessor :bs_local

    # Bundle ID of the test application
    attr_accessor :app_bundle_id

    # Farm username
    attr_accessor :username

    # Farm access key
    attr_accessor :access_key

    # Test device type
    attr_accessor :device

    # A list of devices to attempt to connect to, in order
    attr_accessor :device_list

    # Test browser type
    attr_accessor :browser

    # A list of browsers to attempt to connect to, in order
    attr_accessor :browser_list

    # Test browser version
    attr_accessor :browser_version

    # The appActivity to be set in the Appium capabilities
    attr_accessor :app_activity

    # The appPackage to be set in the Appium capabilities
    attr_accessor :app_package

    # Appium version to use
    attr_accessor :appium_version

    # URL of the Appium server
    attr_accessor :appium_server_url

    # URL of the Selenium server
    attr_accessor :selenium_server_url

    # Whether the legacy (JSON-WP) Appium driver should be used
    def legacy_driver?
      @legacy_driver
    end

    def legacy_driver=(value)
      @legacy_driver = value
    end

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
