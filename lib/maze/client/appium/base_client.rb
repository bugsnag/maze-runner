require 'bugsnag'
require 'json'

# Custom error class for reporting successful Appium sessions
class Success < StandardError
  def initialize(message)
    super(message)
    @message = message
  end

  def to_s
    @message
  end
end

module Maze
  module Client
    module Appium
      class BaseClient
        FIXTURE_CONFIG = 'fixture_config.json'

        def initialize
          @start_attempts = 0
        end

        def start_session
          prepare_session

          start_driver(Maze.config)

          # Set bundle/app id for later use
          unless Maze.config.app.nil?
            Maze.driver.app_id = case Maze::Helper.get_current_platform
                                 when 'android'
                                   Maze.driver.session_capabilities['appPackage']
                                 when 'ios'
                                   unless app_id = Maze.driver.session_capabilities['CFBundleIdentifier']
                                      app_id = Maze.driver.session_capabilities['bundleId']
                                   end
                                   app_id
                                 end
          end

          $logger.error "Failed to determine app id." if Maze.driver.app_id.nil?

          # Log the device information after it's started
          write_device_info

          # Ensure the device is unlocked
          begin
            Maze::Api::Appium::DeviceManager.new.unlock
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

        def write_device_info
          info = Maze::Api::Appium::DeviceManager.new.info
          filepath = File.join(Dir.pwd, 'maze_output', 'device_info.json')
          File.open(filepath, 'w+') do |file|
            file.puts(JSON.pretty_generate(info))
          end
        rescue => error
          $logger.warn "Could not write device information file, #{error.message}"
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
            @session_metadata = Maze::Client::Appium::SessionMetadata.new
            @session_metadata.id = driver.session_id
            @session_metadata.farm = Maze.config.farm.to_s
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
          if Maze.driver.failed?
            @session_metadata.success = false
            @session_metadata.failure_message = Maze.driver.failure_reason
          else
            # TODO: The call to quit could also fail
            Maze.driver.driver_quit
            @session_metadata.success = true
          end

          # Report session outcome to Bugsnag
          report_session if ENV['MAZE_APPIUM_BUGSNAG_API_KEY']

          Maze::AppiumServer.stop if Maze::AppiumServer.running
        end

        def report_session
          if @session_metadata.success
            error = Success.new('Success')
          else
            error = ::Selenium::WebDriver::Error::ServerError.new(@session_metadata.failure_message)
          end

          Bugsnag.notify(error) do |event|
            event.api_key = ENV['MAZE_APPIUM_BUGSNAG_API_KEY']

            metadata = {
              'session id': @session_metadata.id,
              'success': @session_metadata.success,
              'device farm': @session_metadata.farm.to_s,
            }
            metadata['device'] = @session_metadata.device if @session_metadata.device

            if @session_metadata.success
              event.severity = 'info'
            else
              event.severity = 'error'
              event.unhandled = true
              metadata['failure message'] = @session_metadata.failure_message
            end

            event.add_metadata(:'Appium Session', metadata)
          end
        end
      end
    end
  end
end
