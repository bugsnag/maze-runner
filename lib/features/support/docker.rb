require_relative 'runner'

class Docker
  class << self
    COMPOSE_FILENAME = 'features/fixtures/docker-compose.yml'

    def start_service(service, command: nil)
      if command
        # We build the service before running it as there is no --build
        # option for run.
        run_docker_compose_command("build #{service}")
        run_docker_compose_command("run -d --use-aliases #{service} #{command}")
      else
        run_docker_compose_command("up -d --build #{service}")
      end
    end

    def down_service(service)
      # We set timeout to 0 so this kills the services rather than stopping them
      # as its quicker and they are stateless anyway.
      run_docker_compose_command("down -t 0 #{service}")
    end

    def down_all_services
      # This will fail to remove the network that maze is connected to
      # as it is still in use, that is ok to ignore so we pass success codes!
      # We set timeout to 0 so this kills the services rather than stopping them
      # as its quicker and they are stateless anyway.
      run_docker_compose_command("down -t 0", success_codes: [0,256]) if compose_stack_exists?
    end

    def compose_project_name
      @compose_project_name ||= nil
    end

    def compose_project_name=(project_name)
      @compose_project_name = project_name
    end

    private
    def run_docker_compose_command(command, compose_file:COMPOSE_FILENAME, success_codes:nil)
      project_name = compose_project_name.nil? ? "" : "-p #{compose_project_name}"
      command = "docker-compose #{project_name} -f #{compose_file} #{command}"
      Runner.run_command(command, success_codes: success_codes)
    end

    def compose_stack_exists?
      File.exist? COMPOSE_FILENAME
    end
  end
end

After do |scenario|
  # This is here to stop sessions from one test hitting another.
  # However this does mean that tests take longer.
  # TODO:SM We could try and fix this by generating unique endpoints
  # for each test.
  Docker.down_all_services
end

at_exit do
  # In order to not impact future test runs, we down
  # all services (which removes networks etc) so that
  # future test runs are from a clean slate.
  Docker.down_all_services
end