$api_key = '12312312312312312312312312312312'
ENV['BUGSNAG_API_KEY'] = $api_key

AfterConfiguration do |_config|
  Maze.config.enforce_bugsnag_integrity = false
end
