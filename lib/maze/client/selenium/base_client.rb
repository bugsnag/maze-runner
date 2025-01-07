module Maze
  module Client
    module Selenium
      class BaseClient
        def start_session
          raise 'Method not implemented by this class'
        end

        def start_driver(config, selenium_url, max_attempts = 5)
          attempts = 0

          while attempts < max_attempts && Maze.driver.nil?
            attempts += 1
            start_error = nil

            $logger.trace "Attempting to start Selenium driver with capabilities: #{config.capabilities.to_json}"
            $logger.trace "Attempt #{attempts}"
            begin
              Maze.driver = Maze::Driver::Browser.new(:remote, selenium_url, config.capabilities)
              Maze.driver.start_driver
            rescue => error
              $logger.error "Session creation failed: #{error}"
              start_error = error
            end

            unless Maze.driver
              interval = handle_start_error(config, start_error)
              if interval.nil? || attempts >= max_attempts
                $logger.error 'Failed to create Selenium driver, exiting'
                Kernel.exit(::Maze::Api::ExitCode::SESSION_CREATION_FAILURE)
              else
                $logger.warn "Failed to create Selenium driver, retrying in #{interval} seconds"
                $logger.info "Error: #{start_error.message}" if start_error
                Kernel.sleep(interval)
              end
            end
          end
        end

        def handle_start_error(config, error)
          notify = true
          interval = nil

          # Used if we have a want to determine fatal errors later
          case error.class.to_s
          when 'Selenium::WebDriver::Error::WebDriverError'
            interval = 5
            notify = false
          else
            interval = 10
          end

          Bugsnag.notify error if notify

          unless config.browser_list.empty?
            # If the list is empty we have only one browser to continue with
            config.browser = config.browser_list.shift
            config.capabilities = create_capabilities(config)
          end

          interval
        end

        def log_run_outro
          raise 'Method not implemented by this class'
        end

        def stop_session
          Maze.driver.driver_quit unless Maze.driver.failed?
        end
      end
    end
  end
end
