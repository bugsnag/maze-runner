# Contains logic for the Cucumber hooks when in Appium mode
module Maze
  module Hooks
    class AppiumHooks < InternalHooks
      def after_configuration
        # Setup Appium capabilities.  Note that the 'app' capability is
        # set in a hook as it will change if uploaded to BrowserStack.

        # BrowserStack specific setup
        config = Maze.config
        if config.farm == :bs
          tunnel_id = SecureRandom.uuid
          # BrowserStack device
          config.capabilities = Maze::Capabilities.for_browser_stack_device config.device,
                                                                            tunnel_id,
                                                                            config.appium_version,
                                                                            config.capabilities_option

          config.app = Maze::BrowserStackUtils.upload_app config.username,
                                                          config.access_key,
                                                          config.app
          config.capabilities['app'] = config.app
          Maze::BrowserStackUtils.start_local_tunnel config.bs_local,
                                                     tunnel_id,
                                                     config.access_key
        elsif config.farm == :bb
          if ENV['BUILDKITE']
            credentials = Maze::BitBarUtils.account_credentials config.tms_uri
            config.username = credentials[:username]
            config.access_key = credentials[:access_key]
          end
          config.app = Maze::BitBarUtils.upload_app config.access_key,
                                                    config.app
          Maze::BitBarUtils.start_local_tunnel config.bb_local,
                                              config.username,
                                              config.access_key
          config.capabilities = Maze::Capabilities.for_bitbar_device config.access_key,
                                                                    config.device,
                                                                    config.capabilities_option
          config.capabilities['bitbar_app'] = config.app
          config.capabilities['bundleId'] = config.app_bundle_id
        elsif config.farm == :local
          # Local device
          config.capabilities = Maze::Capabilities.for_local config.os,
                                                             config.capabilities_option,
                                                             config.apple_team_id,
                                                             config.device_id
          config.capabilities['app'] = config.app

          # Attempt to start the local appium server
          appium_uri = URI(config.appium_server_url)
          Maze::AppiumServer.start(address: appium_uri.host,
                                   port: appium_uri.port) if config.start_appium
        end

        Maze.driver = if Maze.config.resilient
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
        Maze.driver.start_driver unless config.appium_session_isolation

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
          system("killall #{Maze.config.app} && sleep 1")
        elsif [:bb].include? Maze.config.farm
          Maze.driver.launch_app
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
        elsif Maze.config.farm == :bb
          Maze::BitBarUtils.stop_local_tunnel
          Maze::BitBarUtils.release_account(Maze.config.tms_uri)
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
            $logger.info Maze::LogUtil.linkify url, 'BrowserStack session(s)'
          else
            $logger.info "BrowserStack session(s): #{url}"
          end
        end
      end
    end
  end
end
