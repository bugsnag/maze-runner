# frozen_string_literal: true

require 'json'

module Maze
  module Servlets

    # Allows clients to queue up "commands", in the form of Ruby hashes, using Maze::Server.commands.add.  GET
    # requests made to the /command endpoint will then respond with each queued command in turn.
    class CommandServlet < BaseServlet
      # Serves the next command, if these is one.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(request, response)

        if request.query.nil?
          # Non-idempotent mode - return the "current" command
          commands = Maze::Server.commands

          if commands.size_remaining == 0
            response.body = '{"action": "noop", "message": "No commands queued"}'
            response.status = 200
          else
            command = commands.current
            command_json = JSON.pretty_generate(command)
            command[:uuid] = Maze.run_uuid
            response.body = command_json
            response.status = 200
            commands.next
          end
        else
          # Idempotent mode
          if request.to_query['id'].nil?
            response.body = "'id' is the only recognised query parameter"
            response.status = 400
          elsif request.to_query['id'].downcase == 'all'
            return_all_commands(response)
          end
        end

        response.header['Access-Control-Allow-Origin'] = '*'
      end

      def return_all_commands(response)
        commands = Maze::Server.commands
        commands.all.each { |command| command[:uuid] = Maze.run_uuid }

        command_json = JSON.pretty_generate(command)
        response.body = command_json
        response.status = 200
      end

      def return_command(id, response)
        commands = Maze::Server.commands

        size = commands.size_all
        if id < size
          # Respond with the specific command requested
          command = commands.get(id)
          command_json = JSON.pretty_generate(command)
          command[:uuid] = Maze.run_uuid
          response.body = command_json
          response.status = 200
        else
          response.body = "Requested id=#{id} is invalid for a commands list of size #{size}"
          response.status = 400
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


