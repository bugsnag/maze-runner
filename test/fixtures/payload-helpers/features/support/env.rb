ENV["BUGSNAG_API_KEY"] = $api_key

BeforeAll do
  Maze.config.enforce_bugsnag_integrity = false
end
