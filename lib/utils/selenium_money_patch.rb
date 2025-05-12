# Log the full response so we see more than just the error code
module Selenium
  module WebDriver
    module Error
      class ServerError < StandardError
        def initialize(response)
          $logger.info "In the monkey patch for ServerError"
          if response.is_a? String
            super(response)
          elsif response.is_a?(Selenium::WebDriver::Remote::Response)
            $logger.info "It is a Selenium::WebDriver::Remote::Response: #{response.inspect}"
            if response?.payload.has?("message")
              $logger.info "It has a message"
              super("Status code #{response.code}: #{response.payload['message']}")
            else
              super(response.inspect)
            end
          else
            super(response.inspect)
          end
        end
      end # ServerError
    end # Error
  end # WebDriver
end # Selenium
