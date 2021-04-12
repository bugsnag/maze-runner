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
            text 'Server options:'

            opt Option::BIND_ADDRESS,
                'Mock server bind address',
                short: :none,
                type: :string
            opt Option::PORT,
                'Mock server port',
                short: :none,
                default: 9339

            text ''
            text 'Appium options:'

            opt Option::SEPARATE_SESSIONS,
                'Start a new Appium session for each scenario',
                short: :none,
                type: :boolean,
                default: false
            opt Option::FARM,
                'Device farm to use: "bs" (BrowserStack) or "local"',
                short: '-f',
                type: :string
            opt Option::APP,
                'The app to be installed and run against',
                short: '-a',
                type: :string
            opt Option::A11Y_LOCATOR,
                'Locate elements by accessibility id rather than id',
                short: :none,
                type: :boolean,
                default: false
            opt Option::RESILIENT,
                'Use the resilient Appium driver',
                short: '-r',
                default: false
            opt Option::CAPABILITIES,
                'Additional desired Appium capabilities as a JSON string',
                short: '-c',
                default: '{}'

            text ''
            text 'Device farm options:'

            # TODO: Descriptions
            opt Option::DEVICE,
                'BrowserStack device to use (a key of BrowserStackDevices.DEVICE_HASH)',
                short: :none,
                type: :string
            opt Option::BROWSER,
                'BrowserStack browser to use (an entry in browsers.yml)',
                short: :none,
                type: :string
            opt Option::USERNAME,
                'Device farm username. Consumes env var from environment based on farm set',
                short: '-u',
                type: :string
            opt Option::ACCESS_KEY,
                'Device farm access key. Consumes env var from environment based on farm set',
                short: '-p',
                type: :string
            opt Option::APPIUM_VERSION,
                'The Appium version to use with BrowserStack',
                short: :none,
                type: :string

            # BrowserStack-only options
            opt Option::BS_LOCAL,
                '(BS only) Path to the BrowserStackLocal binary. MAZE_BS_LOCAL env var or "/BrowserStackLocal" by default',
                short: :none,
                type: :string

            # Sauce Labs-only options
            opt Option::SL_LOCAL,
                '(SL only) Path to the Sauce Connect binary. MAZE_SL_LOCAL env var or "/sauce-connect/bin/sc" by default',
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
            opt Option::APPIUM_SERVER,
                'Appium server URL, only used for --farm=local. MAZE_APPIUM_SERVER env var or "http://localhost:4723/wd/hub" by default',
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

            opt Option::LOG_REQUESTS,
                "Log a list of received requests in the event of test failure",
                short: :none,
                type: :boolean,
                default: true

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
            options[Option::USERNAME] ||= ENV['BROWSER_STACK_USERNAME']
            options[Option::ACCESS_KEY] ||= ENV['BROWSER_STACK_ACCESS_KEY']
          when 'sl'
            options[Option::USERNAME] ||= ENV['SAUCE_LABS_USERNAME']
            options[Option::ACCESS_KEY] ||= ENV['SAUCE_LABS_ACCESS_KEY']
          end
          options[Option::BS_LOCAL] ||= ENV['MAZE_BS_LOCAL'] || '/BrowserStackLocal'
          options[Option::SL_LOCAL] ||= ENV['MAZE_SL_LOCAL'] || '/sauce-connect/bin/sc'
          options[Option::APPIUM_SERVER] ||= ENV['MAZE_APPIUM_SERVER'] || 'http://localhost:4723/wd/hub'
          options[Option::APPLE_TEAM_ID] ||= ENV['MAZE_APPLE_TEAM_ID']
          options[Option::UDID] ||= ENV['MAZE_UDID']
          options
        end
      end
    end
  end
end
