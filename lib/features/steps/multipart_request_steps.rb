require 'test/unit'
require 'open-uri'
require 'json'
require 'cgi'

include Test::Unit::Assertions

# @!group Multipart request assertion steps

# Verifies that the request contains multipart form-data
Then('the request is valid multipart form-data') do
  steps %(
    Then the "Content-Type" header matches the regex "^multipart\\/form-data; boundary=[\\h-]+$"
    And the multipart request has a non-empty body
  )
end

# Tests the number of fields a multipart request contains.
#
# @step_input part_count [Integer] The number of expected fields
Then('the multipart request has {int} fields') do |part_count|
  parts = Server.current_request[:body]
  assert_equal(part_count, parts.size)
end

# Tests the multipart request has at least one field.
Then('the multipart request has a non-empty body') do
  parts = Server.current_request[:body]
  assert(parts.size.positive?, "Multipart request payload contained #{parts.size} fields")
end

# (Deprecated) Retained for backwards compatibility.
# Use "the payload field {string} is not null"
#
# Tests that a multipart request field exists and is not null.
#
# @step_input part_key [String] The key to the multipart element
Then('the field {string} for multipart request is not null') do |part_key|
  step %(the multipart field "#{part_key}" is not null)
end

# (Deprecated) Retained for backwards compatibility
# Use "the payload field {string} equals {string}"
#
# Tests that a multipart request field equals a string.
#
# @step_input part_key [String] The key to the multipart element
# @step_input expected_value [String] The string to match against
Then('the field {string} for multipart request equals {string}') do |part_key, expected_value|
  step %(the multipart field "#{part_key}" equals "#{expected_value}")
end

# (Deprecated) Retained for backwards compatibility
# Use "the payload field {string} is null"
#
# Tests that a multipart request field is null.
#
# @step_input part_key [String] The key to the multipart element
Then('the field {string} for multipart request is null') do |part_key|
  step %(the multipart field "#{part_key}" is null)
end

# Takes a hashmap and parses all fields into strings or hashes depending on their format
# Used to convert a multipart/form-data request into a JSON comparable hash
#
# @param body [Hash] The multipart/form-data hash to parse
#
# @return [Hash] The result of parsing hash fields to strings/JSON hashes
def parse_multipart_body(body)
  body.each_with_object({}) do |(k, v), out|
    out[k] = JSON.parse(v.to_s)
  rescue JSON::ParserError
    out[k] = v.to_s
  end
end

# Tests that the multipart payload body does not match a JSON file.
# JSON formatted multipart fields will be parsed into hashes.
#
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the multipart body does not match the JSON file in {string}') do |json_path|
  assert_true(File.exist?(json_path, "'#{json_path}' does not exist"))
  raw_payload_value = Server.current_request[:body]
  payload_value = parse_multipart_body(raw_payload_value)
  expected_value = JSON.parse(open(json_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end

# Tests that the multipart payload body matches a JSON fixture.
# JSON formatted multipart fields will be parsed into hashes.
#
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the multipart body matches the JSON file in {string}') do |json_path|
  assert_true(File.exist?(json_path, "'#{json_path}' does not exist"))
  raw_payload_value = Server.current_request[:body]
  payload_value = parse_multipart_body(raw_payload_value)
  expected_value = JSON.parse(open(json_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Tests that a multipart field matches a JSON fixture.
# The field will be parsed into a hash.
#
# @step_input field_path [String] Path to the tested element
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the multipart field {string} matches the JSON file in {string}') do |field_path, json_path|
  assert_true(File.exist?(json_path, "'#{json_path}' does not exist"))
  payload_value = JSON.parse(Server.current_request[:body][field_path].to_s)
  expected_value = JSON.parse(open(json_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The multipart field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end
