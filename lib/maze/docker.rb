# frozen_string_literal: true

require_relative 'runner'

module Maze
  # Responsible for running docker containers in the local environment
  class Docker
    class << self
      # The default place to look for the docker-compose file
      COMPOSE_FILENAME = 'features/fixtures/docker-compose.yml'

      # @!attribute [a] last_exit_code Provides access to the exit code of the last run docker command
      attr_accessor :last_exit_code

      # @!attribute [a] last_command_logs Provides access to the output from the last run docker command
      attr_accessor :last_command_logs

      # Builds and starts a service, using a command if given.
      # If running a command, it will be executed as an attached process, otherwise it
      # will run detached.
      #
      # @param service [String] The name of the service to start
      # @param command [String] Optional. The command to use when running the service
      # @param interactive [Boolean] Optional. Whether to run interactively
      def start_service(service, command: nil, interactive: false)
        if interactive
          run_docker_compose_command("build #{service}")

          # Run the built service in an interactive session. The service _must_
          # have an appropriate entrypoint, e.g. '/bin/sh'. We also disable ANSI
          # escape sequences from docker-compose as they can cause issues with
          # stderr expectations by 'leaking' into the next line
          command = get_docker_compose_command("--no-ansi run #{service} #{command}")

          cli = Runner.start_interactive_session(command)
          cli.on_exit do |status|
            @last_exit_code = status
            @last_command_logs = cli.stdout_lines + cli.stderr_lines
          end

          # The logs and exit code aren't available from the interactive session
          # at this point (we've just started it!) so we can't provide them here
          @last_command_logs = []
          @last_exit_code = nil
        elsif command
          # We build the service before running it as there is no --build
          # option for run.
          run_docker_compose_command("build #{service}")
          run_docker_compose_command("run --use-aliases #{service} #{command}")
        else
          # TODO: Consider adding a logs command here
          run_docker_compose_command("up -d --build #{service}")
        end
        @services_started = true
      end

      # Kills a running service
      #
      # @param service [String] The name of the service to kill
      def down_service(service)
        # We set timeout to 0 so this kills the services rather than stopping them
        # as its quicker and they are stateless anyway.
        run_docker_compose_command("down -t 0 #{service}")
      end

      # Resets any state ready for the next scenario
      def reset
        down_all_services
        @last_exit_code = nil
        @last_command_logs = nil
      end

      # Kills all running services
      def down_all_services
        # This will fail to remove the network that maze is connected to
        # as it is still in use, that is ok to ignore so we pass success codes!
        # We set timeout to 0 so this kills the services rather than stopping them
        # as its quicker and they are stateless anyway.
        run_docker_compose_command('down -t 0', success_codes: [0, 256]) if compose_stack_exists? && @services_started
        @services_started = false
      end

      def compose_project_name
        @compose_project_name ||= nil
      end

      attr_writer :compose_project_name

      private

      def get_docker_compose_command(command)
        project_name = compose_project_name.nil? ? '' : "-p #{compose_project_name}"

        "docker-compose #{project_name} -f #{COMPOSE_FILENAME} #{command}"
      end

      def run_docker_compose_command(command, success_codes: nil)
        command = get_docker_compose_command(command)

        @last_command_logs, @last_exit_code = Runner.run_command(command, success_codes: success_codes)
      end

      def compose_stack_exists?
        File.exist? COMPOSE_FILENAME
      end
    end
  end
end
