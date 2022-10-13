module Maze
  module Client
    module Appium
      class BitBarClient < BaseClient
        def prepare_session
          config = Maze.config
          if ENV['BUILDKITE']
            credentials = Maze::Client::BitBarClientUtils.account_credentials config.tms_uri
            config.username = credentials[:username]
            config.access_key = credentials[:access_key]
          end
          config.app = Maze::Client::BitBarClientUtils.upload_app config.access_key,
                                                                  config.app
          Maze::Client::BitBarClientUtils.start_local_tunnel config.sb_local,
                                                             config.username,
                                                             config.access_key
        end

        def device_capabilities
          config = Maze.config
          capabilities = {
            'disabledAnimations' => 'true',
            'noReset' => 'true',
            'bitbar:options' => {
              'apiKey' => config.access_key,
              'app' => config.app,
              'testrun' => "#{config.os} #{config.os_version}",
              'findDevice' => false,
              'testTimeout' => 7200,
            }
          }
          capabilities['appiumVersion'] = config.appium_version unless config.appium_version.nil?
          capabilities.deep_merge! BitBarDevices.get_device(config.device,
                                                            config.os,
                                                            config.os_version,
                                                            config.access_key)
          capabilities.deep_merge! JSON.parse(config.capabilities_option)
          capabilities
        end

        def log_session_info
          # Not yet implemented
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
