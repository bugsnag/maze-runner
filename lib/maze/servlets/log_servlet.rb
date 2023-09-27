# frozen_string_literal: true

require 'bugsnag'

module Maze
  module Servlets

    # Receives log requests sent from the test fixture
    class LogServlet < BaseServlet
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
          request: request,
          response: response
        }
        @requests.add(hash)

        response.header['Access-Control-Allow-Origin'] = '*'
        response.status = Server.status_code('POST')
      rescue JSON::ParserError => e
        Bugsnag.notify e
        msg = "Unable to parse request as JSON: #{e.message}"
        $logger.error msg
        Server.invalid_requests.add({
          reason: msg,
          request: request,
          response: response,
          body: request.body
        })
      rescue StandardError => e
        Bugsnag.notify e
        $logger.error "Invalid log request: #{e.message}"
        Server.invalid_requests.add({
          invalid: true,
          reason: e.message,
          request: {
            request_uri: request.request_uri,
            header: request.header.to_h,
            body: request.inspect
          },
          response: response
        })
      end

      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        super

        response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.status = Server.status_code('OPTIONS')
      end
    end
  end
end
