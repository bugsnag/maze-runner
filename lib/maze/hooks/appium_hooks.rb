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
          config.app = Maze::Farm::BrowserStack::Utils.upload_app config.username,
                                                                  config.access_key,
                                                                  config.app
          Maze::Farm::BrowserStack::Utils.start_local_tunnel config.bs_local,
                                                             tunnel_id,
                                                             config.access_key
        when :bb
          if ENV['BUILDKITE']
            credentials = Maze::BitBarUtils.account_credentials config.tms_uri
            config.username = credentials[:username]
            config.access_key = credentials[:access_key]
          end
          config.app = Maze::BitBarUtils.upload_app config.access_key,
                                                    config.app
          Maze::SmartBearUtils.start_local_tunnel config.sb_local,
                                                  config.username,
                                                  config.access_key
        when :local
          # Attempt to start the local appium server
          appium_uri = URI(config.appium_server_url)
          Maze::AppiumServer.start(address: appium_uri.host, port: appium_uri.port) if config.start_appium
        end

        start_driver(config, tunnel_id)

        # Set bundle/app id for later use
        Maze.driver.app_id = case Maze::Helper.get_current_platform
                             when 'android'
                               Maze.driver.session_capabilities['appPackage']
                             when 'ios'
                               Maze.driver.session_capabilities['bundleId']
                             end
        # Ensure the device is unlocked
        Maze.driver.unlock

        # Write links to device farm sessions, where applicable
        write_session_link
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
        elsif [:bb].include? Maze.config.farm
          Maze.driver.launch_app
        else
          Maze.driver.terminate_app Maze.driver.app_id
          Maze.driver.activate_app Maze.driver.app_id
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
          Maze::Farm::BrowserStack::Utils.stop_local_tunnel
        elsif Maze.config.farm == :bb
          Maze::SmartBearUtils.stop_local_tunnel
          Maze::BitBarUtils.release_account(Maze.config.tms_uri) if ENV['BUILDKITE']
        end
      end

      def write_session_link
        config = Maze.config
        if config.farm == :bs && (config.device || config.browser)
          # Log a link to the BrowserStack session search dashboard
          build = Maze.driver.capabilities[:build]
          url = "https://app-automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
          if ENV['BUILDKITE']
            $logger.info Maze::LogUtil.linkify url, 'BrowserStack session(s)'
          else
            $logger.info "BrowserStack session(s): #{url}"
          end
        end
      end

      def device_capabilities(config, tunnel_id = nil)
        case config.farm
        when :bs
          capabilities = Maze::Farm::BrowserStack::Capabilities.device config.device,
                                                                       tunnel_id,
                                                                       config.appium_version,
                                                                       config.capabilities_option
          capabilities['app'] = config.app
        when :local
          capabilities = Maze::Capabilities.for_local config.os,
                                                      config.capabilities_option,
                                                      config.apple_team_id,
                                                      config.device_id
          capabilities['app'] = config.app
        when :bb
          capabilities = Maze::Capabilities.for_bitbar_device config.access_key,
                                                              config.device,
                                                              config.os,
                                                              config.os_version,
                                                              config.capabilities_option
          capabilities['bitbar:options']['app'] = config.app
          # capabilities['appium:bundleId'] = config.app_bundle_id
        end

        $logger.info "Capabilities: #{capabilities.inspect}"


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
        retry_failure = config.device_list.empty?
        until Maze.driver
          begin
            config.capabilities = device_capabilities(config, tunnel_id)
            driver = create_driver(config)

            start_driver_closure = Proc.new do
              begin
                driver.start_driver
                true
              rescue => start_error
                raise start_error unless retry_failure
                false
              end
            end

            unless config.appium_session_isolation
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
    end
  end
end
