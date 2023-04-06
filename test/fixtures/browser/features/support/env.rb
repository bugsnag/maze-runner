require 'yaml'

def get_test_url(path)
  if Maze.config.aws_public_ip
    "http://#{Maze.public_address}#{path}"
  else
    "http://bs-local.com:#{FIXTURES_SERVER_PORT}#{path}"
  end

end

BeforeAll do
  Maze.config.receive_no_requests_wait = 15
  Maze.config.enforce_bugsnag_integrity = false

  FIXTURES_SERVER_PORT = '9020'
  DEV_NULL = Gem.win_platform? ? 'NUL' : '/dev/null'
    pid = Process.spawn({"PORT"=>FIXTURES_SERVER_PORT},
                        'ruby features/lib/server.rb',
                        :out => DEV_NULL,
                        :err => DEV_NULL)
  Process.detach(pid)
end

at_exit do
  # Stop the web page server
  begin
    Process.kill('KILL', pid)
  rescue
  end
end
