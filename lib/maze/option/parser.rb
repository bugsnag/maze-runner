# frozen_string_literal: true

require 'cucumber/cli/main'
require 'optimist'
require_relative '../option'
require_relative '../../maze'

module Maze
  module Option
    # Parses the command line options
    class Parser
      class << self
        def parse(args)
          parser = Optimist::Parser.new do
            text 'Maze Runner extends the functionality of Cucumber, ' \
              'providing all of the command line arguments that it provides.'
            text ''
            text 'Usage [OPTIONS] <filenames>'
            text ''
            text 'Overridden Cucumber options:'
            opt :help,
                'Print this help.'
            opt :version,
                'Display Maze Runner and Cucumber versions'
            opt :expand,
                'Output for Scenario Outlines is expanded by default, suppress using --no-expand',
            short: :none

            text ''
            text 'General options:'

            opt Option::AWS_PUBLIC_IP,
                'Intended for use on Buildkite with the Elastic CI Stack for CI.  Enables awareness of being run with a public IP address.',
                type: :boolean,
                short: :none,
                default: false

            opt Option::RETRIES,
                'Enables retrying failed scenarios when tagged',
                type: :boolean,
                short: :none,
                default: true

            opt Option::BUGSNAG,
                'Enables reporting to Bugsnag on scenario failure (requires MAZE_BUGSNAG_API_KEY for errors, MAZE_SCENARIO_BUGSNAG_API_KEY for test failures)',
                type: :boolean,
                short: :none,
                default: true

            opt Option::BUGSNAG_REPEATER_API_KEY,
                'Enables forwarding of all received POST requests to Bugsnag, using the API key provided.  MAZE_REPEATER_API_KEY may also be set.',
                short: :none,
                type: :string

            opt Option::HUB_REPEATER_API_KEY,
                'Enables forwarding of all received POST requests to InsightHub, using the API key provided.  MAZE_HUB_REPEATER_API_KEY may also be set.',
                short: :none,
                type: :string

            text ''
            text 'Server options:'

            opt Option::HTTPS,
                'Use HTTPS for the mock server',
                short: :none,
                type: :boolean,
                default: false
            opt Option::BIND_ADDRESS,
                'Mock server bind address',
                short: :none,
                type: :string
            opt Option::PORT,
                'Mock server port, defaulting to MAZE_PORT or 9339',
                short: :none,
                type: :integer
            opt Option::NULL_PORT,
                'Terminating connection port',
                short: :none,
                default: 9341

            text ''
            text 'Document server options:'

            opt Option::DS_ROOT,
                'Document server root',
                short: :none,
                type: :string

            text ''
            text 'Appium options:'

            opt Option::FARM,
                'Device farm to use: "bs" (BrowserStack) or "local"',
                short: :none,
                type: :string
            opt Option::APP,
                'The app to be installed and run against.  Assumed to be contained in a file if prefixed with @.',
                short: :none,
                type: :string
            opt Option::A11Y_LOCATOR,
                'Locate elements by accessibility id rather than id',
                short: :none,
                type: :boolean,
                default: false
            opt Option::CAPABILITIES,
                'Additional desired Appium capabilities as a JSON string',
                short: :none,
                default: '{}'

            text ''
            text 'Device farm options:'

            opt Option::DEVICE,
                'Device to use. Can be listed multiple times to have a prioritised list of devices',
                short: :none,
                type: :string,
                multi: true
            opt Option::BROWSER,
                'Browser to use (an entry in <farm>_browsers.yml). Can be listed multiple times to have a prioritised list of browsers',
                short: :none,
                type: :string,
                multi: true
            opt Option::BROWSER_VERSION,
                'Browser version to use (applies to entries in <farm>_browsers.yml that do not include a version)',
                short: :none,
                type: :string
            opt Option::USERNAME,
                'Device farm username. Consumes env var from environment based on farm set',
                short: :none,
                type: :string
            opt Option::ACCESS_KEY,
                'Device farm access key. Consumes env var from environment based on farm set',
                short: :none,
                type: :string
            opt Option::APP_ACTIVITY,
                'The appActivity to set in the Appium capabilities (for BitBar only)',
                short: :none,
                type: :string
            opt Option::APP_PACKAGE,
                'The appPackage to set in the Appium capabilities (for BitBar only)',
                short: :none,
                type: :string
            opt Option::APPIUM_VERSION,
                'The Appium version to use',
                short: :none,
                type: :string
            opt Option::LIST_DEVICES,
                'Lists the devices available for the configured device farm, or all devices if none are specified',
                short: :none,
                default: false
            opt Option::APP_BUNDLE_ID,
                'The bundle identifier of the test application',
                short: :none,
                type: :string
            opt Option::TUNNEL,
                'Start the device farm secure tunnel',
                short: :none,
                default: true
            opt Option::APPIUM_SERVER,
                "Appium server URL.  Defaults are: \n" +
                "  --farm=local - MAZE_APPIUM_SERVER or http://localhost:4723/wd/hub\n" +
                "  --farm=bb - MAZE_APPIUM_SERVER or https://us-west-mobile-hub.bitbar.com/wd/hub\n" +
                'Not used for --farm=bs',
                short: :none,
                type: :string
            opt Option::SELENIUM_SERVER,
                "Selenium server URL. Only used for --farm=bb, defaulting to MAZE_SELENIUM_SERVER or https://us-west-desktop-hub.bitbar.com/wd/hub",
                short: :none,
                type: :string

            # SmartBear-only options
            opt Option::SB_LOCAL,
                '(SB only) Path to the SBSecureTunnel binary. MAZE_SB_LOCAL env var or "/SBSecureTunnel" by default',
                short: :none,
                type: :string

            # BrowserStack-only options
            opt Option::BS_LOCAL,
                '(BS only) Path to the BrowserStackLocal binary. MAZE_BS_LOCAL env var or "/BrowserStackLocal" by default',
                short: :none,
                type: :string

            text ''
            text 'Local device options:'

            opt Option::OS,
                'OS type to use ("ios", "android")',
                short: :none,
                type: :string
            opt Option::OS_VERSION,
                'The intended OS version when running on a local device',
                short: :none,
                type: :string
            opt Option::START_APPIUM,
                'Whether a local Appium server should be start.  Only used for --farm=local.',
                short: :none,
                default: true
            opt Option::APPIUM_LOGFILE,
                'The file local appium server output is logged to, defaulting to "appium_server.log"',
                short: :none,
                default: 'appium_server.log'
            opt Option::APPLE_TEAM_ID,
                'Apple Team Id, required for local iOS testing. MAZE_APPLE_TEAM_ID env var by default',
                short: :none,
                type: :string
            opt Option::UDID,
                'Apple UDID, required for local iOS testing. MAZE_UDID env var by default',
                short: :none,
                type: :string

            text ''
            text 'Logging options:'

            opt Option::FILE_LOG,
                "Writes lists of received requests to the maze_output folder for all scenarios",
                short: :none,
                type: :boolean,
                default: true

            opt Option::LOG_REQUESTS,
                "Log lists of received requests to the console in the event of scenario failure.  Defaults to true if the BUILDKITE environment variable is set",
                short: :none,
                type: :boolean,
                default: false

            opt Option::ALWAYS_LOG,
                "Always log all received requests at the end of a scenario, whether is passes or fails",
                short: :none,
                type: :boolean,
                default: false

            version "Maze Runner v#{Maze::VERSION} " \
                    "(Cucumber v#{Cucumber::VERSION.strip})"
            text ''
            text 'The Cucumber help follows:'
            text ''
          end

          # Allow for options destined for Cucumber
          parser.ignore_invalid_options = true
          options = parser.parse args
          populate_environmental_defaults(options)

        rescue Optimist::HelpNeeded
          parser.educate
          Cucumber::Cli::Main.new(['--help']).execute!
          exit
        rescue Optimist::VersionNeeded
          puts parser.version
          exit
        end

        # Populates unset options with appropriate environment variables or default values if necessary
        #
        # @param options [Hash] The hash of already-parsed options
        #
        # @returns [Hash] The options hash with environment vars added
        def populate_environmental_defaults(options)
          case options.farm
          when 'bs'
            # Allow browser/device credentials to exist in separate accounts
            if options[Option::BROWSER]
              options[Option::USERNAME] ||= ENV['BROWSER_STACK_BROWSERS_USERNAME'] || ENV['BROWSER_STACK_USERNAME']
              options[Option::ACCESS_KEY] ||= ENV['BROWSER_STACK_BROWSERS_ACCESS_KEY'] ||ENV['BROWSER_STACK_ACCESS_KEY']
            else
              options[Option::USERNAME] ||= ENV['BROWSER_STACK_DEVICES_USERNAME'] || ENV['BROWSER_STACK_USERNAME']
              options[Option::ACCESS_KEY] ||= ENV['BROWSER_STACK_DEVICES_ACCESS_KEY'] ||ENV['BROWSER_STACK_ACCESS_KEY']
            end
          when 'bb'
            options[Option::USERNAME] ||= ENV['BITBAR_USERNAME']
            options[Option::ACCESS_KEY] ||= ENV['BITBAR_ACCESS_KEY']
            options[Option::APPIUM_SERVER] ||= ENV['MAZE_APPIUM_SERVER'] || 'https://us-west-mobile-hub.bitbar.com/wd/hub'
            options[Option::SELENIUM_SERVER] ||= ENV['MAZE_SELENIUM_SERVER'] || 'https://us-west-desktop-hub.bitbar.com/wd/hub'
          end

          options[Option::BUGSNAG_REPEATER_API_KEY] ||= ENV['MAZE_REPEATER_API_KEY']
          options[Option::HUB_REPEATER_API_KEY] ||= ENV['MAZE_HUB_REPEATER_API_KEY']
          options[Option::SB_LOCAL] ||= ENV['MAZE_SB_LOCAL'] || '/SBSecureTunnel'
          options[Option::BS_LOCAL] ||= ENV['MAZE_BS_LOCAL'] || '/BrowserStackLocal'
          options[Option::PORT] ||= ENV['MAZE_PORT'] || 9339
          options[Option::APPIUM_SERVER] ||= ENV['MAZE_APPIUM_SERVER'] || 'http://localhost:4723/wd/hub'
          options[Option::APPLE_TEAM_ID] ||= ENV['MAZE_APPLE_TEAM_ID']
          options[Option::UDID] ||= ENV['MAZE_UDID']
          options
        end
      end
    end
  end
end
