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
        end

        def log_run_outro
          api_client = BitBarApiClient.new(Maze.config.access_key)

          $logger.info 'Appium session(s) created:'
          @session_ids.each do |id|
            link = api_client.get_device_session_ui_link(id)
            pp id
            pp link
            $logger.info Maze::LogUtil.linkify(link, "BitBar session: #{id}") if link
          end
        end

        def stop_session
          super
          Maze::Client::BitBarClientUtils.stop_local_tunnel
          Maze::Client::BitBarClientUtils.release_account(Maze.config.tms_uri) if ENV['BUILDKITE']
        end
      end
    end
  end
end
