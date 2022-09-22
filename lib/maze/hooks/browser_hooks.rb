# Contains logic for the Cucumber hooks when in Browser mode
module Maze
  module Hooks
    # Hooks for Browser mode use
    class BrowserHooks < InternalHooks
      def before_all
        config = Maze.config
        case config.farm
        when :bb
          if ENV['BUILDKITE']
            credentials = Maze::BitBarUtils.account_credentials config.tms_uri
            config.username = credentials[:username]
            config.access_key = credentials[:access_key]
          end
          tunnel_id = SecureRandom.uuid
          config.capabilities = Maze::Capabilities.for_bitbar_browsers config.browser,
                                                                       config.access_key,
                                                                       tunnel_id,
                                                                       config.capabilities_option

          Maze::SmartBearUtils.start_local_tunnel config.sb_local,
                                                  config.username,
                                                  config.access_key
          tunnel_id
        when :bs
          # BrowserStack browser
          tunnel_id = SecureRandom.uuid
          capabilities = {
            'bstack:options' => {
              'local' => 'true',
              'localIdentifier' => tunnel_id
            }
          }
          browsers = YAML.safe_load(File.read("#{__dir__}/../client/selenium/bs_browsers.yml"))
          capabilities.deep_merge! browsers[config.browser]
          capabilities.deep_merge! JSON.parse(config.capabilities_option)
          config.capabilities = Selenium::WebDriver::Remote::Capabilities.new capabilities

          Maze::Client::BrowserStackClientUtils.start_local_tunnel config.bs_local,
                                                                   tunnel_id,
                                                                   config.access_key
        end

        # Create and start the relevant driver
        case config.farm
        when :bb
          # TODO: This probably needs to be settable via an environment variable
          # selenium_url = 'https://us-west-desktop-hub.bitbar.com/wd/hub'
          selenium_url = 'https://eu-desktop-hub.bitbar.com/wd/hub'
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
        when :bs
          selenium_url = "http://#{config.username}:#{config.access_key}@hub.browserstack.com/wd/hub"
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
        when :local
          Maze.driver = Maze::Driver::Browser.new Maze.config.browser.to_sym
        end

        # Write links to device farm sessions, where applicable
        write_session_link
      end

      def at_exit
        if Maze.config.farm == :bs
          Maze::Client::BrowserStackClientUtils.stop_local_tunnel
          Maze.driver.driver_quit
        end
      end

      def write_session_link
        config = Maze.config
        if config.farm == :bs
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
