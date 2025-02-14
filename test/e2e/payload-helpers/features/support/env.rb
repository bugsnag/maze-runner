BeforeAll do
  ENV['BUGSNAG_API_KEY'] = $api_key
end

Before do
  Maze.config.enforce_bugsnag_integrity = false
end

When('I enforce checking of the Bugsnag-Integrity header') do
  Maze.config.enforce_bugsnag_integrity = true
end
