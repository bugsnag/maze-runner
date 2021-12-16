# frozen_string_literal: true

# @!group Log assertion steps

# Tests that a log request matches a given level and message.
#
# @step_input log_level [String] The expected log level
# @step_input message [String] The expected message
Then('the {string} level log message equals {string}') do |log_level, message|
  request = Maze::Server.logs.current
  Maze.check.not_nil(request, 'No log message to check')
  log = request[:body]
  Maze.check.equal(log_level, Maze::Helper.read_key_path(log, 'level'))
  Maze.check.equal(message, Maze::Helper.read_key_path(log, 'message'))
end

# Tests that a log request matches a given level and message regex.
#
# @step_input log_level [String] The expected log level
# @step_input message_regex [String] Regex for the expected message
Then('the {string} level log message matches the regex {string}') do |log_level, message_regex|
  request = Maze::Server.logs.current
  Maze.check.not_nil(request, 'No log message to check')

  log = request[:body]
  Maze.check.equal(log_level, Maze::Helper.read_key_path(log, 'level'))
  regex = Regexp.new(message_regex)
  Maze.check.match(regex, Maze::Helper.read_key_path(log, 'message'))
end
