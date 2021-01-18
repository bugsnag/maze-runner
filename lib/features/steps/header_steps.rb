# frozen_string_literal: true

# @!group Header steps

# Tests that a request header is not null
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input header_name [String] The header to test
Then('the {word} {string} header is not null') do |request_type, header_name|
  assert_not_nil(Maze::Server.list_for(request_type).current[:request][header_name],
                 "The #{request_type} '#{header_name}' header should not be null")
end

# Tests that request header equals a string
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input header_name [String] The header to test
# @step_input header_value [String] The string it should match
Then('the {word} {string} header equals {string}') do |request_type, header_name, header_value|
  assert_not_nil(Maze::Server.list_for(request_type).current[:request][header_name],
                 "The #{request_type} '#{header_name}' header wasn't present in the request")
  assert_equal(header_value, Maze::Server.list_for(request_type).current[:request][header_name])
end

# Tests that a request header matches a regex
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input header_name [String] The header to test
# @step_input regex_string [String] The regex to match with
Then('the {word} {string} header matches the regex {string}') do |request_type, header_name, regex_string|
  regex = Regexp.new(regex_string)
  value = Maze::Server.list_for(request_type).current[:request][header_name]
  assert_match(regex, value)
end

# Tests that a request header matches one of a list of strings
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input header_name [String] The header to test
# @step_input header_values [DataTable] A parsed data table
Then('the {word} {string} header equals one of:') do |request_type, header_name, header_values|
  assert_includes(header_values.raw.flatten, Maze::Server.list_for(request_type).current[:request][header_name])
end

# Tests that a request header is a timestamp.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input header_name [String] The header to test
Then('the {word} {string} header is a timestamp') do |request_type, header_name|
  header = Maze::Server.list_for(request_type).current[:request][header_name]
  assert_match(TIMESTAMP_REGEX, header)
end

# Checks that the Bugsnag-Integrity header is a SHA1 or simple digest
#
# @step_input request_type [String] The type of request (error, session, etc)
When('the {word} Bugsnag-Integrity header is valid') do |request_type|
  assert_true(Maze::Helper.valid_bugsnag_integrity_header(Maze::Server.list_for(request_type).current),
              'Invalid Bugsnag-Integrity header detected')
end

