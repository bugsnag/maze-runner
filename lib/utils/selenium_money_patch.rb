# Log the full response so we see more than just the error code
module Selenium
  module WebDriver
    module Error
      class ServerError < StandardError
        def initialize(response)
          if response.is_a? String
            super(response)
          elsif response.is_a? Selenium::WebDriver::Remote::Response
            super("Status code #{response.code}.  Payload: #{response.payload.inspect}")
          else
            super(response.inspect)
          end
        end
      end # ServerError
    end # Error
  end # WebDriver
end # Selenium
