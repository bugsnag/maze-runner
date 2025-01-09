module Maze
  module Client
    module Selenium
      class BitBarClient < BaseClient
        def start_session
          config = Maze.config
          if Maze::Client::BitBarClientUtils.use_local_tunnel?
            Maze::Client::BitBarClientUtils.start_local_tunnel config.sb_local,
                                                               config.username,
                                                               config.access_key
          end

          create_capabilities(config)

          selenium_url = Maze.config.selenium_server_url
          start_driver(config, selenium_url)
        end

        def create_capabilities(config)
          capabilities = ::Selenium::WebDriver::Remote::Capabilities.new
          capabilities['bitbar_apiKey'] = config.access_key
          browsers = YAML.safe_load(File.read("#{__dir__}/bb_browsers.yml"))
          capabilities.merge! BitBarClientUtils.dashboard_capabilities
          capabilities['version'] = config.browser_version unless config.browser_version.nil?
          capabilities.merge! browsers[config.browser]
          capabilities.merge! JSON.parse(config.capabilities_option)
          capabilities['bitbar:options']['testTimeout'] = 900
          capabilities['acceptInsecureCerts'] = true unless Maze.config.browser.include? 'ie_'
          capabilities['bitbar_apiKey'] = config.access_key if Maze::Client::BitBarClientUtils.use_local_tunnel?
          config.capabilities = capabilities
        end

        def log_run_outro
          api_client = BitBarApiClient.new(Maze.config.access_key)

          $logger.info 'Selenium session created:'
          id = Maze.driver.session_id
          link = api_client.get_device_session_ui_link(id)
          $logger.info Maze::Loggers::LogUtil.linkify link, 'BitBar session(s)' if link
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
