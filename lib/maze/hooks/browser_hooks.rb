# Contains logic for the Cucumber hooks when in Browser mode
module Maze
  module Hooks
    # Hooks for Browser mode use
    class BrowserHooks < InternalHooks
      def before_all
        config = Maze.config
        if config.farm == :bs
          # BrowserStack browser
          tunnel_id = SecureRandom.uuid
          config.capabilities = Maze::Capabilities.for_browser_stack_browser config.browser,
                                                                             tunnel_id,
                                                                             config.capabilities_option
          Maze::BrowserStackUtils.start_local_tunnel config.bs_local,
                                                     tunnel_id,
                                                     config.access_key
        end

        # Create and start the relevant driver
        case config.farm
        when :bs
          selenium_url = "http://#{config.username}:#{config.access_key}@hub.browserstack.com/wd/hub"
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
        when :local
          Maze.driver = Maze::Driver::Browser.new Maze.config.browser.to_sym
        end
      end
    end
  end
end
