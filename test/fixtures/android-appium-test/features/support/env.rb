BeforeAll do
  $api_key = '12312312312312312312312312312312'
  ENV['BUGSNAG_API_KEY'] = $api_key
  Maze.config.enforce_bugsnag_integrity = false
  # Deliberately low threshold to test the warning
  Maze.config.receive_requests_slow_threshold = 1
end
