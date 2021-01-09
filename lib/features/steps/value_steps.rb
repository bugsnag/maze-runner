require 'date'

# @!group Value steps

#
# Error payload steps
#

# Stores a payload value against a key for cross-request comparisons.
#
# @step_input field [String] The payload field to store
# @step_input key [String] The key to store the value against
Then('the payload field {string} is stored as the value {string}') do |field, key|
  value = Maze.read_key_path(Maze::Server.errors.current[:body], field)
  Store.values[key] = value.dup
end

# Tests whether a payload field matches a previously stored payload value
#
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the payload field {string} equals the stored value {string}') do |field, key|
  payload_value = Maze.read_key_path(Maze::Server.errors.current[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_true(result.equal?, "Payload value: #{payload_value} does not equal stored value: #{stored_value}")
end

# Tests whether a payload field is distinct from a previously stored payload value
#
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the payload field {string} does not equal the stored value {string}') do |field, key|
  payload_value = Maze.read_key_path(Maze::Server.errors.current[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_false(result.equal?, "Payload value: #{payload_value} equals stored value: #{stored_value}")
end

# Tests whether a payload field is a number (Numeric according to Ruby)
#
# @step_input field [String] The payload field to test
Then('the payload field {string} is a number') do |field|
  value = Maze.read_key_path(Maze::Server.errors.current[:body], field)
  assert_kind_of Numeric, value
end

# Tests whether a payload field is an integer (Integer according to Ruby)
#
# @step_input field [String] The payload field to test
Then('the payload field {string} is an integer') do |field|
  value = Maze.read_key_path(Maze::Server.errors.current[:body], field)
  assert_kind_of Integer, value
end

# Tests whether a payload field is a date (parseable as a Date, according to Ruby)
#
# @step_input field [String] The payload field to test
Then('the payload field {string} is a date') do |field|
  value = Maze.read_key_path(Maze::Server.errors.current[:body], field)
  date = begin
           Date.parse(value)
         rescue StandardError
           nil
         end
  assert_kind_of Date, date
end

# Tests whether a payload field (loosely) matches a UUID regex (/[a-fA-F0-9-]{36}/)
#
# @step_input field [String] The payload field to test
Then('the payload field {string} is a UUID') do |field|
  value = Maze.read_key_path(Maze::Server.errors.current[:body], field)
  assert_not_nil(value, "Expected UUID, got nil for #{field}")
  match = /[a-fA-F0-9-]{36}/.match(value).size > 0
  assert_true(match, "Field #{field} is not a UUID, received #{value}")
end

#
# Session payload steps
#

# Stores a session payload value against a key for cross-request comparisons.
#
# @step_input field [String] The session payload field to store
# @step_input key [String] The key to store the value against
Then('the session payload field {string} is stored as the value {string}') do |field, key|
  value = Maze.read_key_path(Maze::Server.sessions.current[:body], field)
  Store.values[key] = value.dup
end

# Tests whether a session payload field matches a previously stored payload value
#
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the session payload field {string} equals the stored value {string}') do |field, key|
  payload_value = Maze.read_key_path(Maze::Server.sessions.current[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_true(result.equal?, "Payload value: #{payload_value} does not equal stored value: #{stored_value}")
end

# Tests whether a session payload field is distinct from a previously stored payload value
#
# @step_input field [String] The session payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the session payload field {string} does not equal the stored value {string}') do |field, key|
  payload_value = Maze.read_key_path(Maze::Server.sessions.current[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_false(result.equal?, "Payload value: #{payload_value} equals stored value: #{stored_value}")
end

# Tests whether a payload field is a number (Numeric according to Ruby)
#
# @step_input field [String] The payload field to test
Then('the session payload field {string} is a number') do |field|
  value = Maze.read_key_path(Maze::Server.sessions.current[:body], field)
  assert_kind_of Numeric, value
end

# Tests whether a payload field is an integer (Integer according to Ruby)
#
# @step_input field [String] The payload field to test
Then('the session payload field {string} is an integer') do |field|
  value = Maze.read_key_path(Maze::Server.sessions.current[:body], field)
  assert_kind_of Integer, value
end

# Tests whether a payload field is a date (parseable as a Date, according to Ruby)
#
# @step_input field [String] The payload field to test
Then('the session payload field {string} is a date') do |field|
  value = Maze.read_key_path(Maze::Server.sessions.current[:body], field)
  date = begin
           Date.parse(value)
         rescue StandardError
           nil
         end
  assert_kind_of Date, date
end

# Tests whether a payload field (loosely) matches a UUID regex (/[a-fA-F0-9-]{36}/)
#
# @step_input field [String] The payload field to test
Then('the session payload field {string} is a UUID') do |field|
  value = Maze.read_key_path(Maze::Server.sessions.current[:body], field)
  assert_not_nil(value, "Expected UUID, got nil for #{field}")
  match = /[a-fA-F0-9-]{36}/.match(value).size > 0
  assert_true(match, "Field #{field} is not a UUID, received #{value}")
end

# @!endgroup
