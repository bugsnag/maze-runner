AfterConfiguration do |_config|
  Maze.config.document_server_root = 'features/fixtures'
  Maze.config.enforce_bugsnag_integrity = false
end
