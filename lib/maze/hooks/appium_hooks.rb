# Contains logic for the Cucumber hooks when in Appium mode
module Maze
  module Hooks
    # Hooks for Appium mode use
    class AppiumHooks < InternalHooks
      def before_all
        # Setup Appium capabilities.  Note that the 'app' capability is
        # set in a hook as it will change if uploaded to BrowserStack.

        config = Maze.config
        case config.farm
        when :bs
          tunnel_id = SecureRandom.uuid
          config.app = Maze::BrowserStackUtils.upload_app config.username,
                                                          config.access_key,
                                                          config.app
          Maze::BrowserStackUtils.start_local_tunnel config.bs_local,
                                                     tunnel_id,
                                                     config.access_key
        when :sl
          config.app = Maze::SauceLabsUtils.upload_app config.username,
                                                       config.access_key,
                                                       config.app
          tunnel_id = SecureRandom.uuid
          Maze::SauceLabsUtils.start_sauce_connect config.sl_local,
                                                   tunnel_id,
                                                   config.username,
                                                   config.access_key
        when :local
          # Attempt to start the local appium server
          appium_uri = URI(config.appium_server_url)
          Maze::AppiumServer.start(address: appium_uri.host, port: appium_uri.port) if config.start_appium
        end

        start_driver(config, tunnel_id)

        # Write links to device farm sessions, where applicable
        write_session_links
      end

      def before
        Maze.driver.start_driver if Maze.config.farm != :none && Maze.config.appium_session_isolation

        # Launch the app on macOS, if Appium is being used
        Maze.driver.get(Maze.config.app) if Maze.driver && Maze.config.os == 'macos'
      end

      def after
        if Maze.config.appium_session_isolation
          Maze.driver.driver_quit
        elsif Maze.config.os == 'macos'
          # Close the app - without the sleep, launching the app for the next scenario intermittently fails
          system("killall -KILL #{Maze.config.app} && sleep 1")
        else
          Maze.driver.reset
        end
      end

      def at_exit
        # Stop the Appium session and server
        Maze.driver.driver_quit unless Maze.config.appium_session_isolation
        Maze::AppiumServer.stop if Maze::AppiumServer.running

        if Maze.config.farm == :local && Maze.config.os == 'macos'
          # Acquire and output the logs for the current session
          Maze::Runner.run_command("log show --predicate '(process == \"#{Maze.config.app}\")' --style syslog --start '#{Maze.start_time}' > #{Maze.config.app}.log")
        elsif Maze.config.farm == :bs
          Maze::BrowserStackUtils.stop_local_tunnel
        elsif Maze.config.farm == :sl
          $logger.info 'Stopping Sauce Connect'
          Maze::SauceLabsUtils.stop_sauce_connect
        end
      end

      def write_session_links
        config = Maze.config
        if config.farm == :bs && (config.device || config.browser)
          # Log a link to the BrowserStack session search dashboard
          build = Maze.driver.capabilities[:build]
          url = if config.device
                  "https://app-automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
                else
                  "https://automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
                end
          if ENV['BUILDKITE']
            $logger.info Maze::LogUtil.linkify url, 'BrowserStack Build URL'
          else
            $logger.info "BrowserStack session(s): #{url}"
          end
        end
      end

      def device_capabilities(config, tunnel_id = nil)
        case config.farm
        when :bs
          capabilities = Maze::Capabilities.for_browser_stack_device config.device,
                                                                     tunnel_id,
                                                                     config.appium_version,
                                                                     config.capabilities_option
          capabilities['app'] = config.app
        when :sl
          capabilities = Maze::Capabilities.for_sauce_labs_device config.device,
                                                                  config.os,
                                                                  config.os_version,
                                                                  tunnel_id,
                                                                  config.appium_version,
                                                                  config.capabilities_option
          capabilities['app'] = "storage:#{config.app}"
        when :local
          capabilities = Maze::Capabilities.for_local config.os,
                                                      config.capabilities_option,
                                                      config.apple_team_id,
                                                      config.device_id
          capabilities['app'] = config.app
        end
        capabilities
      end

      def create_driver(config)
        if Maze.config.resilient
          $logger.info 'Creating ResilientAppium driver instance'
          Maze::Driver::ResilientAppium.new config.appium_server_url,
                                            config.capabilities,
                                            config.locator
        else
          $logger.info 'Creating Appium driver instance'
          Maze::Driver::Appium.new config.appium_server_url,
                                   config.capabilities,
                                   config.locator
        end
      end

      def start_driver(config, tunnel_id = nil)
        until Maze.driver
          begin
            config.capabilities = device_capabilities(config, tunnel_id)
            driver = create_driver(config)
            driver.start_driver unless config.appium_session_isolation
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

      def after_all
        sleep 10
        build_info = Maze::BrowserStackUtils.build_info Maze.config.username,
                                                        Maze.config.access_key,
                                                        Maze.driver.capabilities[:build]
        build_info.each_with_index do |session, index|
          $logger.info "Downloading Device Logs for Session #{index + 1}"

          Maze::BrowserStackUtils.download_log Maze.config.username,
                                               Maze.config.access_key,
                                               session['automation_session']['device_logs_url'],
                                               index + 1

          $logger.info "Downloading Appium Logs for Session #{index + 1}"

          Maze::BrowserStackUtils.download_log Maze.config.username,
                                               Maze.config.access_key,
                                               session['automation_session']['appium_logs_url'],
                                               index + 1
        end
      end
    end
  end
end
