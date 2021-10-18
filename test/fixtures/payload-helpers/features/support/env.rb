BeforeAll do
  ENV['BUGSNAG_API_KEY'] = $api_key

  Maze.config.enforce_bugsnag_integrity = false
end
