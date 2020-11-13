# frozen_string_literal: true

require_relative 'runner'

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
    def start_service(service, command: nil)
      if command
        # We build the service before running it as there is no --build
        # option for run.
        run_docker_compose_command("build #{service}")
        run_docker_compose_command("run --use-aliases #{service} #{command}")
      else
        run_docker_compose_command("up -d --build #{service}")
        # TODO: Consider adding a logs command here
      end
    end

    # Kills a running service
    #
    # @param service [String] The name of the service to kill
    def down_service(service)
      # We set timeout to 0 so this kills the services rather than stopping them
      # as its quicker and they are stateless anyway.
      run_docker_compose_command("down -t 0 #{service}")
    end

    # Kills all running services
    def down_all_services
      # This will fail to remove the network that maze is connected to
      # as it is still in use, that is ok to ignore so we pass success codes!
      # We set timeout to 0 so this kills the services rather than stopping them
      # as its quicker and they are stateless anyway.
      run_docker_compose_command('down -t 0', success_codes: [0, 256]) if compose_stack_exists?
    end

    def compose_project_name
      @compose_project_name ||= nil
    end

    attr_writer :compose_project_name

    private

    def run_docker_compose_command(command, compose_file: COMPOSE_FILENAME, success_codes: nil)
      project_name = compose_project_name.nil? ? '' : "-p #{compose_project_name}"
      command = "docker-compose #{project_name} -f #{compose_file} #{command}"
      @last_exit_code, @last_command_logs = Runner.run_command(command, success_codes: success_codes)
    end

    def compose_stack_exists?
      File.exist? COMPOSE_FILENAME
    end
  end
end
