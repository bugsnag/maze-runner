require 'open3'
require_relative './fast-selenium'
require 'yaml'

module Browserstack
  class Driver
    attr_reader :driver
    attr_accessor :capabilities

    def initialize(username, access_key, local_id)
      @username = username
      @access_key = access_key
      @local_id = local_id
      @capabilities = {
        'browserstack.console': 'errors',
        'browserstack.localIdentifier': local_id,
        'browserstack.local': 'true'
      }

      at_exit do
        @driver.quit unless @driver.nil?
      end
    end

    def start_local_tunnel
      status = nil
      Open3.popen2("/BrowserStackLocal -d start --key #{@access_key} --local-identifier #{@local_id} --force-local") do |stdin, stdout, wait|
        status = wait.value
      end
      status
    end
  end
end