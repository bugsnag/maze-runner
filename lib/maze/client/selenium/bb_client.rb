module Maze
  module Client
    module Selenium
      class BitBarClient < BaseClient
        def start_session
          config = Maze.config
          capabilities = ::Selenium::WebDriver::Remote::Capabilities.new
          capabilities['bitbar_apiKey'] = config.access_key
          capabilities['bitbar:options'] = {
            'testTimeout' => 900
          }
          browsers = YAML.safe_load(File.read("#{__dir__}/bb_browsers.yml"))
          capabilities.deep_merge! BitBarClientUtils.dashboard_capabilities
          capabilities.merge! browsers[config.browser]
          capabilities.merge! JSON.parse(config.capabilities_option)
          config.capabilities = capabilities

          if Maze::Client::BitBarClientUtils.use_local_tunnel?
            capabilities['bitbar_apiKey'] = config.access_key
            Maze::Client::BitBarClientUtils.start_local_tunnel config.sb_local,
                                                               config.username,
                                                               config.access_key
          end

          selenium_url = Maze.config.selenium_server_url
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
          Maze.driver.start_driver
        end

        def log_run_outro
          api_client = BitBarApiClient.new(Maze.config.access_key)

          $logger.info 'Selenium session created:'
          id = Maze.driver.session_id
          link = api_client.get_device_session_ui_link(id)
          $logger.info Maze::LogUtil.linkify link, 'BitBar session(s)' if link
        end

        def stop_session
          super
          if Maze::Client::BitBarClientUtils.use_local_tunnel?
            Maze::Client::BitBarClientUtils.stop_local_tunnel
          end
        end
      end
    end
  end
end
