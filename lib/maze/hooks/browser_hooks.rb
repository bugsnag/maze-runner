# Contains logic for the Cucumber hooks when in Browser mode
module Maze
  class BrowserHooks
    def after_configuration
      if config.farm == :bs
        # BrowserStack browser
        tunnel_id = SecureRandom.uuid
        config.capabilities = Maze::Capabilities.for_browser_stack_browser config.browser,
                                                                           tunnel_id,
                                                                           config.capabilities_option
        Maze::BrowserStackUtils.start_local_tunnel config.bs_local,
                                                   tunnel_id,
                                                   config.access_key

        # Create and start the relevant driver
        if config.farm == :bs
          selenium_url = "http://#{config.username}:#{config.access_key}@hub.browserstack.com/wd/hub"
          Maze.driver = Maze::Driver::Browser.new :remote, selenium_url, config.capabilities
        elsif config.farm == :local
          Maze.driver = Maze::Driver::Browser.new :chrome
        end
      end
    end

    def before

    end

    def after

    end

    def at_exit

    end
  end
end
