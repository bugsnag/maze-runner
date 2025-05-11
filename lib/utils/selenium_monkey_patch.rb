# Log the full response so we see more than just the error code
module Selenium
  module WebDriver
    module Error
      class ServerError < StandardError
        def initialize(response)
          $logger.info "In the monkey patch for ServerError"
          if response.is_a? String
            super(response)
          elsif response.is_a? Selenium::WebDriver::Remote::Response &&
                response.payload.respond_to?("message")
            $logger.info "It is a Selenium::WebDriver::Remote::Response: #{response.inspect}"
            super("Status code #{response.code}: #{response.payload.message}")
          else
            super(response.inspect)
          end
        end
      end # ServerError
    end # Error
  end # WebDriver
end # Selenium
