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
                                                                     @session_uuid,
                                                                     config.access_key
          end
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
            capabilities['bstack:options']['localIdentifier'] = @session_uuid
          end

          capabilities
        end

        def log_session_info
          if Maze.config.device || Maze.config.browser
            # Log device id
            udid = Maze.driver.session_capabilities['udid']
            $logger.info "Running on device: #{udid}" unless udid.nil?

            # Log a link to the BrowserStack session search dashboard
            url = "https://app-automate.browserstack.com/dashboard/v2/search?query=#{@session_uuid}&type=builds"
            if ENV['BUILDKITE']
              $logger.info Maze::LogUtil.linkify(url, 'BrowserStack session(s)')
            else
              $logger.info "BrowserStack session(s): #{url}"
            end
          end
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
            build: @session_uuid
          }
        end
      end
    end
  end
end
