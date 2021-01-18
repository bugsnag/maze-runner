def output_logs
  $docker_services.each do |service|
    logged_service = service[:service] == :all ? '' : service[:service]
    command = "logs -t #{logged_service}"
    begin
      response = run_docker_compose_command(service[:file], command)
    rescue => exception
      response = "Couldn't retrieve logs for #{service[:file]}:#{logged_service}"
    end
    STDOUT.puts response.is_a?(String) ? response : response.to_a
  end
end

AfterConfiguration do |_config|
  Maze.config.enforce_bugsnag_integrity = false
end
