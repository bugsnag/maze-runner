module Maze
  module Client
    module Appium
      class BitBarClient < BaseClient
        def prepare_session
          config = Maze.config
          config.app = Maze::Client::BitBarClientUtils.upload_app config.access_key,
                                                                  config.app
          if Maze::Client::BitBarClientUtils.use_local_tunnel?
            Maze::Client::BitBarClientUtils.start_local_tunnel config.sb_local,
                                                               config.username,
                                                               config.access_key
          end
        end

        def retry_start_driver?
          false
        end

        def start_scenario
          unless Maze.config.legacy_driver?
            # Write Maze's address to file and push to the device
            maze_address = Maze.public_address || "local:#{Maze.config.port}"
            Maze::Api::Appium::FileManager.new.write_app_file(JSON.generate({ maze_address: maze_address }),
                                                              FIXTURE_CONFIG)
          end

          super
        end

        def device_capabilities
          config = Maze.config
          prefix = BitBarDevices.caps_prefix(config.appium_version)
          capabilities = {
            "#{prefix}noReset" => true,
            "#{prefix}newCommandTimeout" => 600,
            'bitbar:options' => {
              # Some capabilities probably belong in the top level
              # of the hash, but BitBar picks them up from here.
              'apiKey' => config.access_key,
              'app' => config.app,
              'findDevice' => false,
              'testTimeout' => 7200
            }
          }
          capabilities.deep_merge! BitBarClientUtils.dashboard_capabilities
          capabilities.deep_merge! BitBarDevices.get_available_device(config.device)
          capabilities.deep_merge! JSON.parse(config.capabilities_option)
          capabilities
        end

        def log_run_intro
          # Nothing to log at the start
        end

        def log_run_outro
          api_client = BitBarApiClient.new(Maze.config.access_key)

          $logger.info 'Appium session(s) created:'
          @session_ids.each do |id|
            link = api_client.get_device_session_ui_link(id)
            $logger.info Maze::LogUtil.linkify(link, "BitBar session: #{id}") if link
          end
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
