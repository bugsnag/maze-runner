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
            opt :init,
                'Initialises a new Maze Runner project'
            opt :version,
                'Display Maze Runner and Cucumber versions'

            # Common options
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

            # BrowserStack-only options
            opt Option::BS_LOCAL,
                '(BS only) Path to the BrowserStackLocal binary. MAZE_BS_LOCAL env var or "/BrowserStackLocal" by default',
                short: :none,
                type: :string
            opt Option::BS_DEVICE,
                'BrowserStack device to use (a key of Devices.DEVICE_HASH)',
                short: :none,
                type: :string
            opt Option::BS_BROWSER,
                'BrowserStack browser to use (an entry in browsers.yml)',
                short: :none,
                type: :string
            opt Option::USERNAME,
                'Device farm username. MAZE_DEVICE_FARM_USERNAME env var by default',
                short: '-u',
                type: :string
            opt Option::ACCESS_KEY,
                'Device farm access key. MAZE_DEVICE_FARM_ACCESS_KEY env var by default',
                short: '-p',
                type: :string
            opt Option::BS_APPIUM_VERSION,
                'The Appium version to use with BrowserStack',
                short: :none,
                type: :string

            # Local-only options
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
            opt Option::APPLE_TEAM_ID,
                'Apple Team Id, required for local iOS testing. MAZE_APPLE_TEAM_ID env var by default',
                short: :none,
                type: :string
            opt Option::UDID,
                'Apple UDID, required for local iOS testing. MAZE_UDID env var by default',
                short: :none,
                type: :string

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
          options[Option::BS_LOCAL] ||= ENV['MAZE_BS_LOCAL'] || '/BrowserStackLocal'
          options[Option::USERNAME] ||= ENV['MAZE_DEVICE_FARM_USERNAME']
          options[Option::ACCESS_KEY] ||= ENV['MAZE_DEVICE_FARM_ACCESS_KEY']
          options[Option::APPIUM_SERVER] ||= ENV['MAZE_APPIUM_SERVER'] || 'http://localhost:4723/wd/hub'
          options[Option::APPLE_TEAM_ID] ||= ENV['MAZE_APPLE_TEAM_ID']
          options[Option::UDID] ||= ENV['MAZE_UDID']
          options
        end
      end
    end
  end
end
