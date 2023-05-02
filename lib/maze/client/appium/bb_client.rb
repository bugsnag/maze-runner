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
            'noReset' => true,
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
          capabilities.deep_merge! dashboard_capabilities
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

        # Determines capabilities used to organise sessions in the BitBar dashboard.
        #
        # @return [Hash] A hash containing the capabilities.
        def dashboard_capabilities

          # Determine project name
          if ENV['BUILDKITE']
            $logger.info 'Using BUILDKITE_PIPELINE_SLUG for BitBar project name'
            project = ENV['BUILDKITE_PIPELINE_SLUG']
          else
            # Attempt to use the current git repo
            output, status = Maze::Runner.run_command('git rev-parse --show-toplevel')
            if status == 0
              project = File.basename(output[0].strip)
            else
              $logger.warn 'Unable to determine project name, consider running Maze Runner from within a Git repository'
              project = 'Unknown'
            end
          end

          # Test run
          if ENV['BUILDKITE']
            bk_retry = ENV['BUILDKITE_RETRY_COUNT']
            retry_string = if !bk_retry.nil? && bk_retry.to_i > 1
                             " (#{bk_retry})"
                           else
                             ''
                           end
            test_run = "#{ENV['BUILDKITE_BUILD_NUMBER']} - #{ENV['BUILDKITE_LABEL']}#{retry_string}"
          else
            test_run = Maze.run_uuid
          end

          $logger.info "BitBar project name: #{project}"
          $logger.info "BitBar test run: #{test_run}"
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
