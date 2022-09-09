# Log the full response so we see more than just the error code
module Selenium
  module WebDriver
    module Error
      class ServerError < StandardError
        def initialize(response)
          if response.is_a? String
            super(response)
          else
            $logger.error "Server response: #{response.inspect}"
            super("status code #{response.code}")
          end
        end
      end # ServerError
    end # Error
  end # WebDriver
end # Selenium
