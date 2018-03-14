require 'open3'

$docker_stack ||= Set.new
$docker_file = nil

def set_compose_file(filename)
  # This command should validate dockerfile early on
  run_docker_compose_command(filename, "config -q")
  $docker_stack << filename
  $docker_file = filename
end

def build_service(service, compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "build #{service}")
end

def start_service(service, compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "up -d #{service}")
end

def stop_service(service, compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "rm -fs #{service}")
end

def kill_service(service, compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "kill #{service}")
end

def test_service_running(service, compose_file=nil, running=true)
  result = run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "ps -q #{service}")
  if running
    assert_equal(1, result.size)
  else
    assert_equal(0, result.size)
  end
end

def start_stack(compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "up -d")
end

def stop_stack(compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "down", false)
end

def run_command_on_service(command, service, compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "exec #{service} #{command}")
end

def run_service_with_command(service, command, compose_file=nil)
  run_docker_compose_command(compose_file.nil? ? $docker_file : compose_file, "run -d #{service} #{command}")
end

def run_docker_compose_command(file, command, must_pass=true)
  environment = @script_env.inject('') {|curr,(k,v)| curr + "#{k}=#{v} "} unless @script_env.nil?
  run_command("#{environment} docker-compose -f #{file} #{command}", must_pass)
end

at_exit do
  $docker_stack.each { |filename| stop_stack(filename) }
end