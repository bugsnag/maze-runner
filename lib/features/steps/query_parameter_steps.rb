# frozen_string_literal: true

# @!group Query parameter steps

# Tests that a query parameter matches a string.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input parameter_name [String] The parameter to test
# @step_input parameter_value [String] The expected value
Then('the {word} {string} query parameter equals {string}') do |request_type, parameter_name, parameter_value|
  assert_equal(parameter_value, Maze::Helper.parse_querystring(Maze::Server.list_for(request_type).current)[parameter_name][0])
end

# Tests that a query parameter is present and not null.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input parameter_name [String] The parameter to test
Then('the {word} {string} query parameter is not null') do |request_type, parameter_name|
  assert_not_nil(Maze::Helper.parse_querystring(Maze::Server.list_for(request_type).current)[parameter_name][0],
                 "The '#{parameter_name}' query parameter should not be null")
end

# Tests that a query parameter is a timestamp.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input parameter_name [String] The parameter to test
Then('the {word} {string} query parameter is a timestamp') do |request_type, parameter_name|
  param = Maze::Helper.parse_querystring(Maze::Server.list_for(request_type).current)[parameter_name][0]
  assert_match(TIMESTAMP_REGEX, param)
end
