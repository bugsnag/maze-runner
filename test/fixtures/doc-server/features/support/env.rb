AfterConfiguration do |_config|
  Maze.config.ds_root = 'features/fixtures'
  Maze.config.enforce_bugsnag_integrity = false
end
