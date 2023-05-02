require 'yaml'

Maze.hooks.before_all do
  Maze.config.receive_no_requests_wait = 15
  Maze.config.enforce_bugsnag_integrity = false
  Maze.config.document_server_root = 'features/fixtures'
end

at_exit do
  # Stop the web page server
  begin
    Process.kill('KILL', pid)
  rescue
  end
end
