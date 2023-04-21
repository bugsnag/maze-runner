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

            text ''
            text 'General options:'

            opt Option::AWS_PUBLIC_IP,
                'Intended for use on Buildkite with the Elastic CI Stack for CI.  Enables awareness of being run with a public IP address.',
                type: :boolean,
                default: false

            opt Option::ENABLE_RETRIES,
                'Enables retrying failed scenarios when tagged',
                type: :boolean,
                default: true

            opt Option::ENABLE_BUGSNAG,
                'Enables reporting to Bugsnag on scenario failure (requires MAZE_BUGSNAG_API_KEY)',
                type: :boolean,
                default: true

            opt Option::REPEATER_API_KEY,
                'Enables forwarding of all received POST requests to Bugsnag, using the API key provided.  MAZE_REPEATER_API_KEY may also be set.',
                type: :string

            text ''
            text 'Server options:'

            opt Option::BIND_ADDRESS,
                'Mock server bind address',
                type: :string
            opt Option::PORT,
                'Mock server port',
                default: 9339
            opt Option::NULL_PORT,
                'Terminating connection port',
                default: 9341

            text ''
            text 'Document server options:'

            opt Option::DS_ROOT,
                'Document server root',
                type: :string
            opt Option::DS_BIND_ADDRESS,
                'Document server bind address',
                type: :string
            opt Option::DS_PORT,
                'Document server port',
                default: 9340

            text ''
            text 'Appium options:'

            opt Option::FARM,
                'Device farm to use: "bs" (BrowserStack) or "local"',
                type: :string
            opt Option::APP,
                'The app to be installed and run against.  Assumed to be contained in a file if prefixed with @.',
                type: :string
            opt Option::A11Y_LOCATOR,
                'Locate elements by accessibility id rather than id',
                type: :boolean,
                default: false
            opt Option::CAPABILITIES,
                'Additional desired Appium capabilities as a JSON string',
                default: '{}'

            text ''
            text 'Device farm options:'

            opt Option::DEVICE,
                'Device to use. Can be listed multiple times to have a prioritised list of devices',
                short: :none,
                type: :string,
                multi: true
            opt Option::BROWSER,
                'Browser to use (an entry in <farm>_browsers.yml)',
                short: :none,
                type: :string
            opt Option::USERNAME,
                'Device farm username. Consumes env var from environment based on farm set',
                type: :string
            opt Option::ACCESS_KEY,
                'Device farm access key. Consumes env var from environment based on farm set',
                type: :string
            opt Option::APPIUM_VERSION,
                'The Appium version to use',
                type: :string
            opt Option::LIST_DEVICES,
                'Lists the devices available for the configured device farm, or all devices if none are specified',
                default: false
            opt Option::APP_BUNDLE_ID,
                'The bundle identifier of the test application',
                type: :string
            opt Option::TUNNEL,
                'Start the device farm secure tunnel',
                default: true
            opt Option::APPIUM_SERVER,
                "Appium server URL.  Defaults are: \n" +
                "  --farm=local - MAZE_APPIUM_SERVER or http://localhost:4723/wd/hub\n" +
                "  --farm=bb - MAZE_APPIUM_SERVER or https://us-west-mobile-hub.bitbar.com/wd/hub\n" +
                'Not used for --farm=bs',
                type: :string
            opt Option::SELENIUM_SERVER,
                "Selenium server URL.  Only used for--farm=bb, defaulting to MAZE_SELENIUM_SERVER or https://us-west-desktop-hub.bitbar.com/wd/hub",
                type: :string

            # SmartBear-only options
            opt Option::SB_LOCAL,
                '(SB only) Path to the SBSecureTunnel binary. MAZE_SB_LOCAL env var or "/SBSecureTunnel" by default',
                type: :string

            # BrowserStack-only options
            opt Option::BS_LOCAL,
                '(BS only) Path to the BrowserStackLocal binary. MAZE_BS_LOCAL env var or "/BrowserStackLocal" by default',
                type: :string

            # TMS options
            opt Option::TMS_URI,
                'URI of the test management server root.  MAZE_TMS_URI env var',
                type: :string

            opt Option::TMS_TOKEN,
                'Token used to access the test management server.  MAZE_TMS_TOKEN env var',
                type: :string

            text ''
            text 'Local device options:'

            opt Option::OS,
                'OS type to use ("ios", "android")',
                type: :string
            opt Option::OS_VERSION,
                'The intended OS version when running on a local device',
                type: :string
            opt Option::START_APPIUM,
                'Whether a local Appium server should be start.  Only used for --farm=local.',
                default: true
            opt Option::APPIUM_LOGFILE,
                'The file local appium server output is logged to, defaulting to "appium_server.log"',
                default: 'appium_server.log'
            opt Option::APPLE_TEAM_ID,
                'Apple Team Id, required for local iOS testing. MAZE_APPLE_TEAM_ID env var by default',
                type: :string
            opt Option::UDID,
                'Apple UDID, required for local iOS testing. MAZE_UDID env var by default',
                type: :string

            text ''
            text 'Logging options:'

            opt Option::FILE_LOG,
                "Writes lists of received requests to the maze_output folder for all scenarios",
                type: :boolean,
                default: true

            opt Option::LOG_REQUESTS,
                "Log lists of received requests to the console in the event of scenario failure.  Defaults to true if the BUILDKITE environment variable is set",
                type: :boolean,
                default: false

            opt Option::ALWAYS_LOG,
                "Always log all received requests at the end of a scenario, whether is passes or fails",
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
            options[Option::TMS_URI] ||= ENV['MAZE_TMS_URI']
            options[Option::APPIUM_SERVER] ||= ENV['MAZE_APPIUM_SERVER'] || 'https://us-west-mobile-hub.bitbar.com/wd/hub'
            options[Option::SELENIUM_SERVER] ||= ENV['MAZE_SELENIUM_SERVER'] || 'https://us-west-desktop-hub.bitbar.com/wd/hub'
          end

          options[Option::REPEATER_API_KEY] ||= ENV['MAZE_REPEATER_API_KEY']
          options[Option::SB_LOCAL] ||= ENV['MAZE_SB_LOCAL'] || '/SBSecureTunnel'
          options[Option::TMS_URI] ||= ENV['MAZE_TMS_URI']
          options[Option::TMS_TOKEN] ||= ENV['MAZE_TMS_TOKEN']
          options[Option::BS_LOCAL] ||= ENV['MAZE_BS_LOCAL'] || '/BrowserStackLocal'
          options[Option::APPIUM_SERVER] ||= ENV['MAZE_APPIUM_SERVER'] || 'http://localhost:4723/wd/hub'
          options[Option::APPLE_TEAM_ID] ||= ENV['MAZE_APPLE_TEAM_ID']
          options[Option::UDID] ||= ENV['MAZE_UDID']
          options
        end
      end
    end
  end
end
