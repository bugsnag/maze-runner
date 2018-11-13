require 'open3'

$docker_stack ||= Set.new
$docker_compose_file = nil
$docker_services = Set.new

DEFAULT_STACK_PATH = "features/fixtures/"
DEFAULT_STACK_NAME = "docker-compose.{yml,yaml}"

def find_default_docker_compose
  if Dir.exist? DEFAULT_STACK_PATH
    Dir.chdir DEFAULT_STACK_PATH do
      file = Dir.glob(DEFAULT_STACK_NAME).first
      return if file.nil?

      # Check for errors in the compose file
      output = run_docker_compose_command(file, "config -q", false)
      if output.size == 0
        full_file = DEFAULT_STACK_PATH + file
        $docker_compose_file = full_file
      end
    end
  end
end

def clear_docker_services
  $docker_services = Set.new
end

def set_compose_file(filename)
  # This command should validate dockerfile early on
  run_docker_compose_command(filename, "config -q")
  $docker_stack << filename
  $docker_compose_file = filename
end

def build_service(service, compose_file=$docker_compose_file)
  run_docker_compose_command(compose_file, "build #{service}")
end

def start_service(service, compose_file=$docker_compose_file)
  $docker_services << {
    :file => compose_file,
    :service => service
  }
  run_docker_compose_command(compose_file, "up -d --build #{service}")
end

def stop_service(service, compose_file=$docker_compose_file)
  run_docker_compose_command(compose_file, "rm -fs #{service}")
end

def kill_service(service, compose_file=$docker_compose_file)
  run_docker_compose_command(compose_file, "kill #{service}")
end

def test_service_running(service, running=true, compose_file=$docker_compose_file)
  result = run_docker_compose_command(compose_file, "ps -q #{service}")
  if running
    assert_equal(1, result.size)
  else
    assert_equal(0, result.size)
  end
end

def start_stack(compose_file=$docker_compose_file)
  $docker_services << {
    :file => compose_file,
    :service => :all
  }
  run_docker_compose_command(compose_file, "up -d --build")
end

def stop_stack(compose_file=$docker_compose_file)
  run_docker_compose_command(compose_file, "down", false)
end

def run_command_on_service(command, service, compose_file=$docker_compose_file)
  run_docker_compose_command(compose_file, "exec -T #{service} #{command}")
end

def run_service_with_command(service, command, compose_file=$docker_compose_file)
  $docker_services << {
    :file => compose_file,
    :service => service
  }
  run_docker_compose_command(compose_file, "run -d #{service} #{command}")
end

def run_docker_compose_command(file, command, must_pass=true)
  command = "docker-compose -f #{file} #{command}"
  run_command(@script_env || {}, command, must_pass: must_pass)
end


def port_open?(ip, port, seconds=1)
  Timeout::timeout(seconds) do
    begin
      TCPSocket.new(ip, port).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      false
    end
  end
rescue Timeout::Error
  false
end

def wait_for_port(port)
  max_attempts = 10
  attempts = 0
  up = false
  until (attempts >= max_attempts) || up
    attempts += 1
    up = port_open?("localhost", port)
    sleep 1
  end
  raise "Port not ready in time!" unless up
end

at_exit do
  $docker_stack.each { |filename| stop_stack(filename) }
end
