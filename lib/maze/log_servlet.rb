# frozen_string_literal: true

module Maze
  # Receives log requests sent from the test fixture
  class LogServlet < WEBrick::HTTPServlet::AbstractServlet
    # Constructor
    #
    # @param server [HTTPServer] WEBrick HTTPServer
    def initialize(server)
      super server
      @requests = Server.logs
    end

    # Logs and parses an incoming POST request.
    # Parses `multipart/form-data` and `application/json` content-types.
    # Parsed requests are added to the requests list.
    #
    # @param request [HTTPRequest] The incoming GET request
    # @param response [HTTPResponse] The response to return
    def do_POST(request, response)
      hash = {
        body: JSON.parse(request.body),
        request: request
      }
      @requests.add(hash)

      response.header['Access-Control-Allow-Origin'] = '*'
      response.status = Server.status_code
    rescue JSON::ParserError => e
      msg = "Unable to parse request as JSON: #{e.message}"
      $logger.error msg
      Server.invalid_requests << {
        reason: msg,
        request: request
      }
    rescue StandardError => e
      $logger.error "Invalid request: #{e.message}"
      Server.invalid_requests << {
        reason: e.message,
        request: request
      }
    end

    # Logs and returns a set of valid headers for this servlet.
    #
    # @param request [HTTPRequest] The incoming GET request
    # @param response [HTTPResponse] The response to return
    def do_OPTIONS(request, response)
      log_request(request)
      response.header['Access-Control-Allow-Origin'] = '*'
      response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
      response.header['Access-Control-Allow-Headers'] = %w[Accept
                                                           Bugsnag-Api-Key Bugsnag-Integrity
                                                           Bugsnag-Payload-Version
                                                           Bugsnag-Sent-At Content-Type
                                                           Origin].join(',')

      response.status = Server.status_code
    end
  end
end
