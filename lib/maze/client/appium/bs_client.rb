module Maze
  module Client
    module Appium
      class BrowserStackClient < BaseClient
        def prepare_session
          # Upload the app and start the secure tunnel
          config.app = Maze::Farm::BrowserStack::Utils.upload_app config.username,
                                                                  config.access_key,
                                                                  config.app
          Maze::Farm::BrowserStack::Utils.start_local_tunnel config.bs_local,
                                                             session_uuid,
                                                             config.access_key
        end

        def device_capabilities
            capabilities = Maze::Farm::BrowserStack::Capabilities.device config.device,
                                                                         tunnel_id,
                                                                         config.appium_version,
                                                                         config.capabilities_option
            capabilities
        end

        def log_session_info
          if Maze.config.device || Maze.config.browser
            # Log a link to the BrowserStack session search dashboard
            build = Maze.driver.capabilities[:build]
            url = "https://app-automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
            if ENV['BUILDKITE']
              $logger.info Maze::LogUtil.linkify(url, 'BrowserStack session(s)')
            else
              $logger.info "BrowserStack session(s): #{url}"
            end
          end
        end

        def stop_session
          super
          Maze::Farm::BrowserStack::Utils.stop_local_tunnel
        end
      end
    end
  end
end
