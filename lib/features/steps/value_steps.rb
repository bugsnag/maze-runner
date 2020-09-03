# @!group Value steps

# Stores a payload value against a key for cross-request comparisons.
#
# @step_input field [String] The payload field to store
# @step_input key [String] The key to store the value against
Then('the payload field {string} is stored as the value {string}') do |field, key|
  value = read_key_path(Server.instance.errors.current[:body], field)
  Store.values[key] = value.dup
end

# Tests whether a payload field matches a previously stored payload value
#
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the payload field {string} equals the stored value {string}') do |field, key|
  payload_value = read_key_path(Server.instance.errors.current[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_true(result.equal?, "Payload value: #{payload_value} does not equal stored value: #{stored_value}")
end

# Tests whether a payload field is distinct from a previously stored payload value
#
# @step_input field [String] The payload field to test
# @step_input key [String] The key indicating a previously stored value
Then('the payload field {string} does not equal the stored value {string}') do |field, key|
  payload_value = read_key_path(Server.instance.errors.current[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_false(result.equal?, "Payload value: #{payload_value} equals stored value: #{stored_value}")
end

# @!endgroup
