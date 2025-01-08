module Maze
  module Client
    module Appium
      class BrowserStackClient < BaseClient
        def prepare_session
          # Upload the app and start the secure tunnel
          config = Maze.config
          config.app = Maze::Client::BrowserStackClientUtils.upload_app config.username,
                                                                        config.access_key,
                                                                        config.app
          if Maze.config.start_tunnel
            Maze::Client::BrowserStackClientUtils.start_local_tunnel config.bs_local,
                                                                     Maze.run_uuid,
                                                                     config.access_key
          end
        end

        # On BrowserStack, wait 10 seconds before retrying if there is another device in the list
        def handle_error(error)
          Bugsnag.notify error unless error.nil?
          config = Maze.config
          if config.device_list.nil? || config.device_list.empty?
            $logger.error 'No further devices to try'
            nil
          else
            config.device = config.device_list.first
            config.device_list = config.device_list.drop(1)
            $logger.warn "Retrying driver initialisation using next device: #{config.device}"
            10
          end
        end

        def start_scenario
          unless Maze.config.legacy_driver?
            # Write Maze's address to file and push to the device
            maze_address = "bs-local.com:#{Maze.config.port}"
            Maze::Api::Appium::FileManager.new.write_app_file(JSON.generate({ maze_address: maze_address }),
                                                              FIXTURE_CONFIG)
          end

          super
        end

        def device_capabilities
          config = Maze.config
          capabilities = {
            'app' => config.app,
            'deviceOrientation' => 'portrait',
            'noReset' => 'true',
            'bstack:options' => {}
          }
          device_caps = Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH[config.device]
          capabilities.deep_merge! device_caps
          capabilities.deep_merge! JSON.parse(config.capabilities_option)
          capabilities.merge! project_name_capabilities
          capabilities['bstack:options']['appiumVersion'] = config.appium_version unless config.appium_version.nil?
          unless device_caps['platformName'] == 'android' && device_caps['platformVersion'].to_i <= 6
            capabilities['bstack:options']['disableAnimations'] = 'true'
          end
          if Maze.config.start_tunnel
            capabilities['bstack:options']['local'] = 'true'
            capabilities['bstack:options']['localIdentifier'] = Maze.run_uuid
          end

          capabilities
        end

        def log_run_intro
          # Log a link to the BrowserStack session search dashboard
          $logger.info Maze::Loggers::LogUtil(project_name_capabilities[:project])
          url = "https://app-automate.browserstack.com/projects/#{project_name_capabilities[:project]}/builds/#{Maze.run_uuid}/1?tab=tests"
          $logger.info Maze::Loggers::LogUtil.linkify(url, 'BrowserStack session(s)')
        end

        def log_run_outro
          $logger.info 'Appium session(s) created:'
          @session_ids.each { |id| $logger.info "  #{id}" }
          log_run_intro
        end

        def stop_session
          super
          Maze::Client::BrowserStackClientUtils.stop_local_tunnel if Maze.config.start_tunnel
        end

        private

        # Determines and returns sensible project, build, and name capabilities
        #
        # @return [Hash] A hash containing the 'project' and 'build' capabilities
        def project_name_capabilities
          # Default to values for running locally
          project = 'local'

          if ENV['BUILDKITE']
            # Project
            project = ENV['BUILDKITE_PIPELINE_NAME']
          end
          {
            project: project,
            build: Maze.run_uuid
          }
        end
      end
    end
  end
end
