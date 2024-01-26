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

        def handle_error(error)
          # Retry interval depends on the error message
          return nil if error.nil?

          interval = nil
          notify = true

          if error.message.include? 'no sessionId in returned payload'
            # This will happen naturally due to a race condition in how we access devices
            # Do not notify, but wait long enough for most ghost sessions on BitBar to terminate.
            interval = 60
            notify = false
          elsif error.message.include? 'You reached the account concurrency limit'
            # In theory this shouldn't happen, but back off if it does
            interval = 300
          elsif error.message.include? 'There are no devices available'
            interval = 120
          elsif error.message.include? 'Appium Settings app is not running'
            interval = 10
          else
            # Do not retry in any other case
          end

          Bugsnag.notify error if notify
          interval
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
          # Doubling up on capabilities in both the `appium:options` and `appium` sub dictionaries.
          # See PLAT-11087
          config = Maze.config
          capabilities = {
            'appium:options' => {
              'noReset' => true,
              'newCommandTimeout' => 600
            },
            'appium' => {
              'noReset' => true,
              'newCommandTimeout' => 600
            },
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
          capabilities['bitbar:options']['appiumVersion'] = config.appium_version unless config.appium_version.nil?
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
            $logger.info Maze::Loggers::LogUtil.linkify(link, "BitBar session: #{id}") if link
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
