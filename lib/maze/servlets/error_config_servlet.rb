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

        # Store the query parameters in the error config request list

        # Response with the next error config in the queue, logging and error if the queue is empty

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
