module Maze
  module Client
    module Appium
      class BaseClient
        FIXTURE_CONFIG = 'fixture_config.json'

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
          Maze.driver.unlock

          # Write Maze's address to file and push to the device
          Maze::Api::Appium::FileManager.new.write_app_file("{\"maze_address\": \"#{maze_address}\"}",
                                                            FIXTURE_CONFIG)

          log_session_info
        end

        def prepare_session
          raise 'Method not implemented by this class'
        end

        def maze_address
          raise 'Method not implemented by this class'
        end

        def start_driver(config)
          retry_failure = config.device_list.nil? || config.device_list.empty?
          until Maze.driver
            begin
              config.capabilities = device_capabilities

              $logger.info 'Creating Appium driver instance'
              driver = Maze::Driver::Appium.new config.appium_server_url,
                                                config.capabilities,
                                                config.locator

              start_driver_closure = Proc.new do
                begin
                  driver.start_driver
                  true
                rescue => start_error
                  raise start_error unless retry_failure
                  false
                end
              end

              if retry_failure
                wait = Maze::Wait.new(interval: 10, timeout: 60)
                success = wait.until(&start_driver_closure)

                unless success
                  $logger.error 'Appium driver failed to start after 6 attempts in 60 seconds'
                  raise RuntimeError.new('Appium driver failed to start in 60 seconds')
                end
              else
                start_driver_closure.call
              end

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

              Maze.driver = driver
            rescue Selenium::WebDriver::Error::UnknownError => original_exception
              $logger.warn "Attempt to acquire #{config.device} device from farm #{config.farm} failed"
              $logger.warn "Exception: #{original_exception.message}"
              if config.device_list.empty?
                $logger.error 'No further devices to try - raising original exception'
                raise original_exception
              else
                config.device = config.device_list.first
                config.device_list = config.device_list.drop(1)
                $logger.warn "Retrying driver initialisation using next device: #{config.device}"
              end
            end
          end
        end

        def device_capabilities
          raise 'Method not implemented by this class'
        end

        def log_session_info
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
