require 'date'

# @!group Value steps

# Stores a payload value against a key for cross-request comparisons.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to store
# @step_input key [String] The key to store the value against
Then('the {request_type} payload field {string} is stored as the value {string}') do |request_type, field, key|
  list = Maze::Server.list_for request_type
  value = Maze::Helper.read_key_path(list.current[:body], field)
  Maze::Store.values[key] = value.dup
end

# Tests whether a payload field matches a previously stored payload value
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the {request_type} payload field {string} equals the stored value {string}') do |request_type, field, key|
  list = Maze::Server.list_for request_type
  payload_value = Maze::Helper.read_key_path(list.current[:body], field)
  stored_value = Maze::Store.values[key]
  result = Maze::Compare.value(payload_value, stored_value)
  Maze.check.true(result.equal?, "Payload value: #{payload_value} does not equal stored value: #{stored_value}")
end

# Tests whether a payload field is distinct from a previously stored payload value
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the {request_type} payload field {string} does not equal the stored value {string}') do |request_type, field, key|
  list = Maze::Server.list_for request_type
  payload_value = Maze::Helper.read_key_path(list.current[:body], field)
  stored_value = Maze::Store.values[key]
  result = Maze::Compare.value(payload_value, stored_value)
  Maze.check.false(result.equal?, "Payload value: #{payload_value} equals stored value: #{stored_value}")
end

# Tests whether a payload field matches a previously stored payload value, ignoring case
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the {request_type} payload field {string} equals the stored value {string} ignoring case') do |request_type, field, key|
  list = Maze::Server.list_for request_type
  payload_value = Maze::Helper.read_key_path(list.current[:body], field)
  stored_value = Maze::Store.values[key]
  payload_value.downcase!
  stored_value.downcase!
  result = Maze::Compare.value(payload_value, stored_value)
  Maze.check.true(result.equal?, "Payload value: #{payload_value} does not equal stored value: #{stored_value}")
end

# Tests whether a payload field is distinct from a previously stored payload value, ignoring case
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the {request_type} payload field {string} does not equal the stored value {string} ignoring case') do |request_type, field, key|
  list = Maze::Server.list_for request_type
  payload_value = Maze::Helper.read_key_path(list.current[:body], field)
  stored_value = Maze::Store.values[key]
  payload_value.downcase!
  stored_value.downcase!
  result = Maze::Compare.value(payload_value, stored_value)
  Maze.check.false(result.equal?, "Payload value: #{payload_value} equals stored value: #{stored_value}")
end

# Tests whether a payload field is a number (Numeric according to Ruby)
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
Then('the {request_type} payload field {string} is a number') do |request_type, field|
  list = Maze::Server.list_for request_type
  value = Maze::Helper.read_key_path(list.current[:body], field)
  Maze.check.kind_of Numeric, value
end

# Tests whether a payload field is an integer (Integer according to Ruby)
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
Then('the {request_type} payload field {string} is an integer') do |request_type, field|
  list = Maze::Server.list_for request_type
  value = Maze::Helper.read_key_path(list.current[:body], field)
  Maze.check.kind_of Integer, value
end

# Tests whether a payload field is a date (parseable as a Date, according to Ruby)
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
Then('the {request_type} payload field {string} is a date') do |request_type, field|
  list = Maze::Server.list_for request_type
  value = Maze::Helper.read_key_path(list.current[:body], field)
  date = begin
    Date.parse(value)
  rescue StandardError
    nil
  end
  Maze.check.kind_of Date, date
end

# Tests whether a payload field (loosely) matches a UUID regex (/[a-fA-F0-9-]!{36}/)
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload field to test
Then('the {request_type} payload field {string} is a UUID') do |request_type, field|
  list = Maze::Server.list_for request_type
  value = Maze::Helper.read_key_path(list.current[:body], field)
  Maze.check.not_nil(value, "Expected UUID, got nil for #{field}")
  match = /[a-fA-F0-9-]{36}/.match(value).size > 0
  Maze.check.true(match, "Field #{field} is not a UUID, received #{value}")
end

# @!endgroup
