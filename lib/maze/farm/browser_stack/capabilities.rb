module Maze
  module Farm
    module BrowserStack
      class Capabilities
        class << self
          # @param device_type [String] A key from @see Maze::Farm::BrowserStack::Devices::DEVICE_HASH
          # @param local_id [String] unique key for the tunnel instance
          # @param capabilities_option [String] extra capabilities provided on the command line
          def device(device_type, local_id, appium_version, capabilities_option)
            capabilities = {
              'bstack:options' => {
                'local' => 'true',
                'localIdentifier' => local_id
              },
              'noReset' => 'true'
            }
            capabilities.deep_merge! Maze::Farm::BrowserStack::Devices::DEVICE_HASH[device_type]
            capabilities.deep_merge! JSON.parse(capabilities_option)
            capabilities['bstack:options']['appiumVersion'] = appium_version unless appium_version.nil?
            capabilities
          end

          # @param browser_type [String] A key from @see browsers_bs.yml
          # @param local_id [String] unique key for the tunnel instance
          # @param capabilities_option [String] extra capabilities provided on the command line
          def browser(browser_type, local_id, capabilities_option)
            capabilities = {
              'bstack:options' => {
                'local' => 'true',
                'localIdentifier' => local_id,
                "os" => "Windows",
                "osVersion" => "8.1"
              }
            }
            browsers = YAML.safe_load(File.read("#{__dir__}/browsers_bs.yml"))
            capabilities.deep_merge! browsers[browser_type]
            capabilities.deep_merge! JSON.parse(capabilities_option)
            Selenium::WebDriver::Remote::Capabilities.new capabilities
          end
        end
      end
    end
  end
end