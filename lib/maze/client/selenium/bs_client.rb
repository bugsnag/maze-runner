require 'selenium-webdriver'

module Maze
  module Client
    module Selenium
      class BrowserStackClient < BaseClient
        def start_session
          # Set up the capabilities
          tunnel_id = SecureRandom.uuid
          browsers = YAML.safe_load(File.read("#{__dir__}/bs_browsers.yml"))

          config = Maze.config
          browser = browsers[config.browser]

          if config.legacy_driver?
            capabilities = Selenium::WebDriver::Remote::Capabilities.new
            capabilities['browserstack.local'] = 'true'
            capabilities['browserstack.localIdentifier'] = tunnel_id
            capabilities['browserstack.console'] = 'errors'

            # Convert W3S capabilities to JSON-WP
            capabilities['browser'] = browser['browserName']
            capabilities['browser_version'] = browser['browserVersion']
            capabilities['device'] = browser['device']
            capabilities['os'] = browser['os']
            capabilities['os_version'] = browser['osVersion']

            capabilities.merge! JSON.parse(config.capabilities_option)
            config.capabilities = capabilities
          else
            capabilities = {
              'bstack:options' => {
                'local' => 'true',
                'localIdentifier' => tunnel_id
              }
            }
            capabilities.deep_merge! browser
            capabilities.deep_merge! JSON.parse(config.capabilities_option)
            config.capabilities = ::Selenium::WebDriver::Remote::Capabilities.new capabilities
          end

          # Start the tunnel
          Maze::Client::BrowserStackClientUtils.start_local_tunnel config.bs_local,
                                                                   tunnel_id,
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

        private

        def log_session_info
          # Log a link to the BrowserStack session search dashboard
          build = Maze.driver.capabilities[:build]
          url = "https://automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
          if ENV['BUILDKITE']
            $logger.info Maze::LogUtil.linkify url, 'BrowserStack session(s)'
          else
            $logger.info "BrowserStack session(s): #{url}"
          end
        end
      end
    end
  end
end
