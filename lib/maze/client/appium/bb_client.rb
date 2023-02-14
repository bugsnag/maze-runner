module Maze
  module Client
    module Appium
      class BitBarClient < BaseClient
        def prepare_session
          config = Maze.config
          config.app = Maze::Client::BitBarClientUtils.upload_app config.access_key,
                                                                  config.app
          if Maze.config.start_tunnel
            Maze::Client::BitBarClientUtils.start_local_tunnel config.sb_local,
                                                               config.username,
                                                               config.access_key
          end
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
          capabilities = {
            'disabledAnimations' => 'true',
            'noReset' => 'true',
            'bitbar:options' => {
              # Some capabilities probably belong in the top level
              # of the hash, but BitBar picks them up from here.
              'apiKey' => config.access_key,
              'app' => config.app,
              'findDevice' => false,
              'testTimeout' => 7200,
              'newCommandTimeout' => 0
            }
          }
          capabilities['appiumVersion'] = config.appium_version unless config.appium_version.nil?
          capabilities.deep_merge! project_name_capabilities
          capabilities.deep_merge! BitBarDevices.get_available_device(config.device)
          capabilities.deep_merge! JSON.parse(config.capabilities_option)
          capabilities
        end

        def log_run_intro
          # Nothing to log at the start
        end

        def log_run_outro
          api_client = BitBarApiClient.new

          $logger.info 'Appium session(s) created:'
          @session_ids.each do |id|
            link = api_client.get_device_session_ui_link(id)
            $logger.info Maze::LogUtil.linkify(link, id) if link
          end
        end

        def stop_session
          super
          if Maze.config.start_tunnel
            Maze::Client::BitBarClientUtils.stop_local_tunnel
          end
        end

        private

        # Determines and returns sensible project, build, and name capabilities
        #
        # @return [Hash] A hash containing the 'project' and 'build' capabilities
        def project_name_capabilities
          # Default to values for running locally
          project = 'Unknown'
          test_run = Maze.run_uuid

          if ENV['BUILDKITE']
            project = ENV['BUILDKITE_PIPELINE_NAME']
            test_run = "#{ENV['BUILDKITE_BUILD_NUMBER']} - #{ENV['BUILDKITE_LABEL']}"
          else
            # Attempt to use the current git repo as the project name
            output, status = Maze::Runner.run_command('git rev-parse --show-toplevel')
            if status == 0
              project = File.basename(output[0].strip)
            end
          end
          {
            'bitbar:options' => {
              bitbar_project: project,
              bitbar_testrun: test_run
            }
          }
        end
      end
    end
  end
end
