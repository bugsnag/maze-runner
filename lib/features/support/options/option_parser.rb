# frozen_string_literal: true

require 'cucumber/cli/main'
require 'optimist'
require_relative '../../../version'

module Maze
  # Parses the command line options
  class OptionParser
    class << self
      def parse(args)
        parser = Optimist::Parser.new do
          text 'Maze Runner extends the functionality of Cucumber, ' \
            'providing all of the command line arguments that it provides.'
          text ''
          text 'Usage [OPTIONS] <filenames>'
          text ''
          text 'Overridden Cucumber options:'
          opt :help, 'Print this help.'
          opt :init, 'Initialises a new Maze Runner project'

          opt :version, 'Display Maze Runner and Cucumber versions'

          # Common options
          opt Option::SEPARATE_SESSIONS,
              'Start a new Appium session for each scenario',
              short: :none,
              type: :boolean,
              default: false
          opt Option::FARM, 'Device farm to use: "bs" (BrowserStack) or "local"', short: '-f', type: :string
          opt Option::APP, 'The app to be installed and run against', short: '-a', type: :string
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
              '(BS only) Path to the BrowserStackLocal binary',
              short: :none,
              type: :string,
              default: '/BrowserStackLocal'
          opt Option::BS_DEVICE,
              'BrowserStack device to use (a key of Devices.DEVICE_HASH)',
              short: :none,
              type: :string
          opt Option::USERNAME, 'Device farm username', short: '-u', type: :string
          opt Option::ACCESS_KEY, 'Device farm access key', short: '-p', type: :string
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
              'Appium server URL, only used for --farm=local',
              short: :none,
              type: :string,
              default: 'http://localhost:4723/wd/hub'
          opt Option::APPLE_TEAM_ID, 'Apple Team Id, required for local iOS testing', short: :none, type: :string
          opt Option::UDID, 'Apple UDID, required for local iOS testing', short: :none, type: :string

          version "Maze Runner v#{BugsnagMazeRunner::VERSION} " \
                  "(Cucumber v#{Cucumber::VERSION.strip})"
          text ''
          text 'The Cucumber help follows:'
          text ''
        end

        # Allow for options destined for Cucumber
        parser.ignore_invalid_options = true
        parser.parse args

      rescue Optimist::HelpNeeded
        parser.educate
        Cucumber::Cli::Main.new(['--help']).execute!
        exit
      rescue Optimist::VersionNeeded
        puts parser.version
        exit
      end
    end
  end
end
