# frozen_string_literal: true

require 'json'

module Maze
  module Servlets

    # Allows clients to queue up "commands", in the form of Ruby hashes, using Maze::Server.commands.add.  GET
    # requests made to the /command endpoint will then respond with each queued command in turn.
    class CommandServlet < BaseServlet
      # Serves the next command, if these is one.
      #
      # @param _request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(_request, response)
        response.header['Access-Control-Allow-Origin'] = '*'

        commands = Maze::Server.commands
        if commands.size_remaining == 0
          response.body = 'No commands to provide'
          response.status = 400
        else
          command = commands.current
          command[:uuid] = Maze::Server.command_uuid
          response.body = JSON.pretty_generate(command)
          response.status = 200
          commands.next
        end
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
