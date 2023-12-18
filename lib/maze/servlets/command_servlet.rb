# frozen_string_literal: true

require 'json'

module Maze
  module Servlets

    # Allows clients to queue up "commands", in the form of Ruby hashes, using Maze::Server.commands.add.  GET
    # requests made to the /command endpoint will then respond with each queued command in turn.
    class CommandServlet < BaseServlet

      NOOP_COMMAND = '{"action": "noop", "message": "No commands queued"}'

      # Serves the next command, if these is one.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(request, response)

        if request.query.empty?
          # Non-idempotent mode - return the "current" command
          commands = Maze::Server.commands

          if commands.size_remaining == 0
            response.body = NOOP_COMMAND
            response.status = 200
          else
            command = commands.current
            response.body = JSON.pretty_generate(command)
            response.status = 200
            commands.next
          end
        else
          $logger.info "request.query = #{request.query}"


          # Idempotent mode
          after_uuid = request.query['after']
          if after_uuid.nil?
            response.body = "'after' is the only recognised query parameter"
            response.status = 400
          else
            return_command(after_uuid, response)
          end
        end

        response.header['Access-Control-Allow-Origin'] = '*'
      end

      def return_command(uuid, response)
        commands = Maze::Server.commands
        if uuid.empty?
          index = -1
        else
          index = commands.all.find_index {|command| command[:uuid] == uuid }
        end
        if index.nil?
          msg = "Request invalid - there is no command with a UUID of #{uuid} to follow on from"
          $logger.error msg
          response.body = msg
          response.status = 400
        else
          if index + 1 < commands.size_all
            # Respond with the next command in the queue
            command = commands.get(index + 1)
            command_json = JSON.pretty_generate(command)
            response.body = command_json
            response.status = 200
          else
            # The UUID given was for the last command in the list
            response.body = NOOP_COMMAND
            response.status = 200
          end
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


