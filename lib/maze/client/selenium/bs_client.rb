require 'selenium-webdriver'

module Maze
  module Client
    module Selenium
      class BrowserStackClient < BaseClient
        def start_session
          config = Maze.config

          # Start the tunnel
          Maze::Client::BrowserStackClientUtils.start_local_tunnel config.bs_local,
                                                                   Maze.run_uuid,
                                                                   config.access_key

          create_capabilities(config)

          # Start the driver
          selenium_url = "https://#{config.username}:#{config.access_key}@hub.browserstack.com/wd/hub"
          start_driver(config, selenium_url)

          # Log details for the session
          log_session_info
        end

        def create_capabilities(config)
          raw_capabilities = {
            'acceptInsecureCerts' => true,
            'bstack:options' => {
              'local' => 'true',
              'localIdentifier' => Maze.run_uuid
            }
          }
          raw_capabilities.deep_merge! JSON.parse(config.capabilities_option)
          raw_capabilities.merge! project_name_capabilities
          add_browser_capabilities(config, raw_capabilities)
          capabilities = ::Selenium::WebDriver::Remote::Capabilities.new raw_capabilities
          config.capabilities = capabilities
        end

        def add_browser_capabilities(config, capabilities)
          browsers = YAML.safe_load(File.read("#{__dir__}/bs_browsers.yml"))
          capabilities.deep_merge! browsers[config.browser]
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
          url = "https://automate.browserstack.com/dashboard/v2/search?query=#{Maze.run_uuid}"
          $logger.info Maze::Loggers::LogUtil.linkify url, 'BrowserStack session(s)'
        end
      end
    end
  end
end
