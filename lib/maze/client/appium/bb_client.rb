module Maze
  module Client
    module Appium
      class BitBarClient < BaseClient
        def prepare_session
          if ENV['BUILDKITE']
            credentials = Maze::BitBarUtils.account_credentials config.tms_uri
            config.username = credentials[:username]
            config.access_key = credentials[:access_key]
          end
          config.app = Maze::BitBarUtils.upload_app config.access_key,
                                                    config.app
          Maze::SmartBearUtils.start_local_tunnel config.sb_local,
                                                  config.username,
                                                  config.access_key
        end

        def device_capabilities
          config = Maze.config
          capabilities = Maze::Capabilities.for_bitbar_device config.access_key,
                                                              config.device,
                                                              config.os,
                                                              config.os_version,
                                                              config.capabilities_option
          capabilities
        end

        def log_session_info
          # Not yet implemented
        end

        def stop_session
          super
          Maze::SmartBearUtils.stop_local_tunnel
          Maze::BitBarUtils.release_account(Maze.config.tms_uri) if ENV['BUILDKITE']
        end
      end
    end
  end
end
