# frozen_string_literal: true

# @!group Header steps

# Tests that a request header is present
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input header_name [String] The header to test
Then('the {request_type} {string} header is present') do |request_type, header_name|
  Maze.check.not_nil(Maze::Server.list_for(request_type).current[:request][header_name],
                     "The #{request_type} '#{header_name}' header should not be null")

  request = Maze::Server.list_for(request_type).current[:request]
  Maze.check.true(request.header.key?(header_name.downcase),
                  "The #{request_type} '#{header_name}' header should be present")
end

# Tests that a request header is not present
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input header_name [String] The header to test
Then('the {request_type} {string} header is not present') do |request_type, header_name|
  request = Maze::Server.list_for(request_type).current[:request]

  Maze.check.false(request.header.key?(header_name.downcase),
                   "The #{request_type} '#{header_name}' header should not be present")
end

# Tests that request header equals a string
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input header_name [String] The header to test
# @step_input header_value [String] The string it should match
Then('the {request_type} {string} header equals {string}') do |request_type, header_name, header_value|
  Maze.check.not_nil(Maze::Server.list_for(request_type).current[:request][header_name],
                     "The #{request_type} '#{header_name}' header wasn't present in the request")
  Maze.check.equal(header_value, Maze::Server.list_for(request_type).current[:request][header_name])
end

# Tests that a request header matches a regex
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input header_name [String] The header to test
# @step_input regex_string [String] The regex to match with
Then('the {request_type} {string} header matches the regex {string}') do |request_type, header_name, regex_string|
  regex = Regexp.new(regex_string)
  value = Maze::Server.list_for(request_type).current[:request][header_name]
  Maze.check.match(regex, value)
end

# Tests that a request header matches one of a list of strings
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input header_name [String] The header to test
# @step_input header_values [DataTable] A parsed data table
Then('the {request_type} {string} header equals one of:') do |request_type, header_name, header_values|
  Maze.check.include(header_values.raw.flatten, Maze::Server.list_for(request_type).current[:request][header_name])
end

# Tests that a request header is a timestamp.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input header_name [String] The header to test
Then('the {request_type} {string} header is a timestamp') do |request_type, header_name|
  header = Maze::Server.list_for(request_type).current[:request][header_name]
  Maze.check.match(TIMESTAMP_REGEX, header)
end

# Checks that the Bugsnag-Integrity header is a SHA1 or simple digest
#
# @step_input request_type [String] The type of request (error, session, build, etc)
When('the {request_type} Bugsnag-Integrity header is valid') do |request_type|
  Maze.check.true(Maze::Helper.valid_bugsnag_integrity_header(Maze::Server.list_for(request_type).current),
                  'Invalid Bugsnag-Integrity header detected')
end

