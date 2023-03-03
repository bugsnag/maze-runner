module Maze
  module Client
    module Selenium
      class BitBarClient < BaseClient
        def start_session
          config = Maze.config
          if ENV['BUILDKITE']
            credentials = Maze::Client::BitBarClientUtils.account_credentials config.tms_uri
            config.username = credentials[:username]
            config.access_key = credentials[:access_key]
          end
          capabilities = ::Selenium::WebDriver::Remote::Capabilities.new
          capabilities['bitbar_apiKey'] = config.access_key
          browsers = YAML.safe_load(File.read("#{__dir__}/bb_browsers.yml"))
          capabilities.merge! browsers[config.browser]
          capabilities.merge! JSON.parse(config.capabilities_option)
          config.capabilities = capabilities

          Maze::Client::BitBarClientUtils.start_local_tunnel config.sb_local,
                                                             config.username,
                                                             config.access_key

          # TODO This probably needs to be settable via an environment variable
          # selenium_url = 'https://us-west-desktop-hub.bitbar.com/wd/hub'
          selenium_url = 'https://eu-desktop-hub.bitbar.com/wd/hub'
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
          Maze.driver.start_driver
          Maze::Plugins::MetricsPlugin.log_event('SeleniumDriverStarted', {
            farm: Maze.config.farm,
            browser: config.browser
          })
        end

        def stop_session
          super
          Maze::Client::BitBarClientUtils.stop_local_tunnel
          Maze::Client::BitBarClientUtils.release_account(Maze.config.tms_uri) if ENV['BUILDKITE']
          Maze::Plugins::MetricsPlugin.log_event('SeleniumDriverStopped', {
            farm: Maze.config.farm,
            browser: config.browser
          })
        end
      end
    end
  end
end
