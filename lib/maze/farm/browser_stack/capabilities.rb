module Maze
  module Farm
    module BrowserStack
      class Capabilities
        class << self
          # @param browser_type [String] A key from @see browsers.yml
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
            browsers = YAML.safe_load(File.read("#{__dir__}/browsers.yml"))
            capabilities.deep_merge! browsers[browser_type]
            capabilities.deep_merge! JSON.parse(capabilities_option)
            Selenium::WebDriver::Remote::Capabilities.new capabilities
          end
        end
      end
    end
  end
end
