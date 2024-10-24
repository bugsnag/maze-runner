require 'selenium-webdriver'

module Maze
  module Client
    module Selenium
      class BrowserStackClient < BaseClient
        def start_session
          # Set up the capabilities
          browsers = YAML.safe_load(File.read("#{__dir__}/bs_browsers.yml"))

          config = Maze.config
          browser = browsers[config.browser]

          if config.legacy_driver?
            capabilities = ::Selenium::WebDriver::Remote::Capabilities.new
            capabilities['browserstack.local'] = 'true'
            capabilities['browserstack.localIdentifier'] = Maze.run_uuid
            capabilities['browserstack.console'] = 'errors'
            capabilities['acceptInsecureCerts'] = 'true'

            # Convert W3S capabilities to JSON-WP
            capabilities['browser'] = browser['browserName']
            capabilities['browser_version'] = browser['browserVersion']
            capabilities['device'] = browser['device']
            capabilities['os'] = browser['os']
            capabilities['os_version'] = browser['osVersion']

            capabilities.merge! JSON.parse(config.capabilities_option)
            capabilities.merge! project_name_capabilities
            config.capabilities = capabilities
          else
            capabilities = {
              'acceptInsecureCerts' => true,
              'bstack:options' => {
                'local' => 'true',
                'localIdentifier' => Maze.run_uuid
              }
            }
            capabilities.deep_merge! browser
            capabilities.deep_merge! JSON.parse(config.capabilities_option)
            capabilities.merge! project_name_capabilities
            config.capabilities = ::Selenium::WebDriver::Remote::Capabilities.new capabilities
          end

          # Start the tunnel
          Maze::Client::BrowserStackClientUtils.start_local_tunnel config.bs_local,
                                                                   Maze.run_uuid,
                                                                   config.access_key

          # Start the driver
          selenium_url = "https://#{config.username}:#{config.access_key}@hub.browserstack.com/wd/hub"
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
          Maze.driver.start_driver

          # Log details for the session
          log_session_info
        end

        def stop_session
          super
          Maze::Client::BrowserStackClientUtils.stop_local_tunnel
        end

        def log_run_outro
          log_session_info
        end

        private

        # Determines and returns sensible project and build capabilities
        #
        # @return [Hash] A hash containing the 'project' and 'build' capabilities
        def project_name_capabilities
          # Default to values for running locally
          project = 'local'

          if ENV['BUILDKITE']
            # Project
            project = ENV['BUILDKITE_PIPELINE_NAME']
          end
          {
            project: project,
            build: Maze.run_uuid
          }
        end

        def log_session_info
          # Log a link to the BrowserStack session search dashboard
          url = "https://automate.browserstack.com/dashboard/v2/search?query=#{Maze.run_uuid}&type=builds"
          $logger.info Maze::Loggers::LogUtil.linkify url, 'BrowserStack session(s)'
        end
      end
    end
  end
end
