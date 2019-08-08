Then("the payload field {string} is stored as the value {string}") do |field, key|
  value = read_key_path(Server.current_request[:body], field)
  Store.values[key] = value.dup
end

Then("the payload field {string} equals the stored value {string}") do |field, key|
  payload_value = read_key_path(Server.current_request[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_true(result.equal?, "Payload value: #{payload_value} does not equal stored value: #{stored_value}")
end

Then("the payload field {string} does not equal the stored value {string}") do |field, key|
  payload_value = read_key_path(Server.current_request[:body], field)
  stored_value = Store.values[key]
  result = value_compare(payload_value, stored_value)
  assert_false(result.equal?, "Payload value: #{payload_value} equals stored value: #{stored_value}")
end