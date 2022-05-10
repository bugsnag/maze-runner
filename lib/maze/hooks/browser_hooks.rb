# Contains logic for the Cucumber hooks when in Browser mode
module Maze
  module Hooks
    # Hooks for Browser mode use
    class BrowserHooks < InternalHooks
      def before_all
        config = Maze.config
        case config.farm
        when :bb
          tunnel_id = SecureRandom.uuid
          config.capabilities = Maze::Capabilities.for_bitbar_browsers config.browser,
                                                                             tunnel_id,
                                                                             config.capabilities_option

          Maze::SmartBearUtils.start_local_tunnel config.sb_local,
                                                  config.username,
                                                  config.access_key,
                                                  tunnel_id
        when :bs
          # BrowserStack browser
          tunnel_id = SecureRandom.uuid
          config.capabilities = Maze::Capabilities.for_browser_stack_browser config.browser,
                                                                             tunnel_id,
                                                                             config.capabilities_option
          Maze::BrowserStackUtils.start_local_tunnel config.bs_local,
                                                     tunnel_id,
                                                     config.access_key
        when :cbt
          # CrossBrowserTesting browser
          tunnel_id = SecureRandom.uuid
          config.capabilities = Maze::Capabilities.for_cbt_browser config.browser,
                                                                   tunnel_id,
                                                                   config.capabilities_option
          Maze::SmartBearUtils.start_local_tunnel config.sb_local,
                                                  config.username,
                                                  config.access_key,
                                                  tunnel_id
        end

        # Create and start the relevant driver
        case config.farm
        when :cbt
          selenium_url = "http://#{config.username}:#{config.access_key}@hub.crossbrowsertesting.com:80/wd/hub"
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
        when :bb
          selenium_url = "https://#{config.username}:#{config.access_key}@appium.bitbar.com/wd/hub"
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
          Maze::BrowserStackUtils.stop_local_tunnel
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
