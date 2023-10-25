require 'bugsnag'
require 'json'

module Maze
  module Client
    module Appium
      class BaseClient
        FIXTURE_CONFIG = 'fixture_config.json'

        def initialize
          @session_ids = []
          @start_attempts = 0
        end

        def start_session
          prepare_session

          start_driver(Maze.config)

          # Set bundle/app id for later use
          Maze.driver.app_id = case Maze::Helper.get_current_platform
                               when 'android'
                                 Maze.driver.session_capabilities['appPackage']
                               when 'ios'
                                 Maze.driver.session_capabilities['CFBundleIdentifier'] # Present on BS and locally
                               end

          # Ensure the device is unlocked
          begin
            Maze.driver.unlock
          rescue => error
            Bugsnag.notify error
            $logger.warn "Failed to unlock device: #{error}"
          end

          log_run_intro
        end

        def prepare_session
          raise 'Method not implemented by this class'
        end

        def maze_address
          raise 'Method not implemented by this class'
        end

        def retry_start_driver?
          raise 'Method not implemented by this class'
        end

        def attempt_start_driver(config)
          config.capabilities = device_capabilities
          driver = Maze::Driver::Appium.new config.appium_server_url,
                                            config.capabilities,
                                            config.locator

          result = driver.start_driver
          if result
            # Log details of this session
            $logger.info "Created Appium session: #{driver.session_id}"
            @session_ids << driver.session_id
            udid = driver.session_capabilities['udid']
            $logger.info "Running on device: #{udid}" unless udid.nil?
          end
          driver
        end

        def start_driver(config, max_attempts = 5)

          attempts = 0

          while attempts < max_attempts && Maze.driver.nil?
            attempts += 1
            start_error = nil
            begin
              Maze.driver = attempt_start_driver(config)
            rescue => error
              $logger.error "Session creation failed: #{error}"
              start_error = error
            end

            if Maze.driver
              # Infer OS version if necessary when running locally
              if Maze.config.farm == :local && Maze.config.os_version.nil?
                version = case Maze.config.os
                          when 'android'
                            driver.session_capabilities['platformVersion'].to_f
                          when 'ios'
                            driver.session_capabilities['sdkVersion'].to_f
                          end
                $logger.info "Inferred OS version to be #{version}"
                Maze.config.os_version = version
              end
            else
              interval = handle_error(start_error)
              if interval && attempts < max_attempts
                $logger.warn "Failed to create Appium driver, retrying in #{interval} seconds"
                Kernel::sleep interval
              else
                $logger.error 'Failed to create Appium driver, exiting'
                Kernel::exit(::Maze::Api::ExitCode::SESSION_CREATION_FAILURE)
              end
            end
          end
        end

        def handle_error(error)
          raise 'Method not implemented by this class'
        end

        def start_scenario
          # Launch the app on macOS
          Maze.driver.get(Maze.config.app) if Maze.config.os == 'macos'
        end

        def device_capabilities
          raise 'Method not implemented by this class'
        end

        def log_run_intro
          raise 'Method not implemented by this class'
        end

        def log_run_outro
          raise 'Method not implemented by this class'
        end

        def stop_session
          Maze.driver&.driver_quit
          Maze::AppiumServer.stop if Maze::AppiumServer.running
        end
      end
    end
  end
end
