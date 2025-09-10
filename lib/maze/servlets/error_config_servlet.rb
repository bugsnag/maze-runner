# frozen_string_literal: true

require 'json'

module Maze
  module Servlets

    # Allows clients to request error configs that have been added to the queue.
    class ErrorConfigServlet < BaseServlet

      # Captures the details of the request for checking and serves the next error config, if there is one.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(request, response)

        # Write to the response with the next error config in the queue, logging and error if the queue is empty

        # Store the query parameters in the error config request list
        details = {
          body: {},
          query: Rack::Utils.parse_nested_query(request.query_string),
          request: request,
          response: response,
          method: 'GET'
        }
        Server.error_config_requests.add(details)
      end

      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        super

        response.header['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
        response.status = Server.status_code('OPTIONS')
      end
    end
  end
end
