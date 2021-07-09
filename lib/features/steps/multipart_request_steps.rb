require 'test/unit'
require 'open-uri'
require 'json'
require 'cgi'

include Test::Unit::Assertions

# @!group Multipart request assertion steps

# Verifies a request contains the correct Content-Type header and some contents
# for a multipart/form-data request
#
# @param request [Hash] The payload to test
def valid_multipart_form_data?(request)
  content_regex = Regexp.new('^multipart\\/form-data; boundary=[\\h-]+$')
  content_header = request[:request]['Content-Type']
  assert_match(content_regex, content_header)
  assert(request[:body].size.positive?, "Multipart request payload contained #{request[:body].size} fields")
end

# Verifies that any type of request contains multipart form-data
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('the {word} request is valid multipart form-data') do |request_type|
  list = Maze::Server.list_for request_type
  valid_multipart_form_data?(list.current)
end

# (Deprecated) Retained for backwards compatibility
# Use "the {word} request is valid multipart form-data"
#
# Verifies that the request contains multipart form-data
Then('the request is valid multipart form-data') do
  $logger.warn 'This step is deprecated and may be removed in a future release'
  step 'the error request is valid multipart form-data'
end

# Verifies all requests of a given type contain multipart form-data
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('all {word} requests are valid multipart form-data') do |request_type|
  list = Maze::Server.list_for request_type
  list.all.all? { |request| valid_multipart_form_data?(request) }
end

# (Deprecated) Retained for backwards compatibility
# Use "all {word} requests are valid multipart form-data"
#
# Verifies all received requests contain multipart form-data
Then('all requests are valid multipart form-data') do
  $logger.warn 'This step is deprecated and may be removed in a future release'
  step 'all error requests are valid multipart form-data'
end

# Tests the number of fields a given type of multipart request contains.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input part_count [Integer] The number of expected fields
Then('the {word} multipart request has {int} fields') do |request_type, part_count|
  list = Maze::Server.list_for request_type
  parts = list.current[:body]
  assert_equal(part_count, parts.size)
end

# (Deprecated) Retained for backwards compatibility
# Use "the {word} multipart request has {int} fields"
#
# Tests the number of fields a multipart request contains.
#
# @step_input part_count [Integer] The number of expected fields
Then('the multipart request has {int} fields') do |part_count|
  $logger.warn 'This step is deprecated and may be removed in a future release'
  step "the error multipart request has #{part_count} fields"
end

# Tests a given type of multipart request has at least one field.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('the {word} multipart request has a non-empty body') do |request_type|
  list = Maze::Server.list_for request_type
  parts = list.current[:body]
  assert(parts.size.positive?, "Multipart request payload contained #{parts.size} fields")
end

# (Deprecated) Retained for backwards compatibility
# Use "the {word} multipart request has a non-empty body"
#
# Tests the multipart request has at least one field.
Then('the multipart request has a non-empty body') do
  $logger.warn 'This step is deprecated and may be removed in a future release'
  step 'the error multipart request has a non-empty body'
end

# (Deprecated) Retained for backwards compatibility.
# Use "the payload field {string} is not null"
#
# Tests that a multipart request field exists and is not null.
#
# @step_input part_key [String] The key to the multipart element
Then('the field {string} for multipart request is not null') do |part_key|
  $logger.warn 'This step is deprecated and may be removed in a future release'
  parts = Maze::Server.errors.current[:body]
  assert_not_nil(parts[part_key], "The field '#{part_key}' should not be null")
end

# (Deprecated) Retained for backwards compatibility
# Use "the payload field {string} equals {string}"
#
# Tests that a multipart request field equals a string.
#
# @step_input part_key [String] The key to the multipart element
# @step_input expected_value [String] The string to match against
Then('the field {string} for multipart request equals {string}') do |part_key, expected_value|
  $logger.warn 'This step is deprecated and may be removed in a future release'
  parts = Maze::Server.errors.current[:body]
  assert_equal(parts[part_key], expected_value)
end

# (Deprecated) Retained for backwards compatibility
# Use "the payload field {string} is null"
#
# Tests that a multipart request field is null.
#
# @step_input part_key [String] The key to the multipart element
Then('the field {string} for multipart request is null') do |part_key|
  $logger.warn 'This step is deprecated and may be removed in a future release'
  parts = Maze::Server.errors.current[:body]
  assert_nil(parts[part_key], "The field '#{part_key}' should be null")
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

# Tests that a given type of multipart payload body does not match a JSON file.
# JSON formatted multipart fields will be parsed into hashes.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the {word} multipart body does not match the JSON file in {string}') do |request_type, json_path|
  assert_true(File.exist?(json_path), "'#{json_path}' does not exist")
  payload_list = Maze::Server.list_for request_type
  raw_payload_value = payload_list.current[:body]
  payload_value = parse_multipart_body(raw_payload_value)
  expected_value = JSON.parse(open(json_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  assert_false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end

# (Deprecated) Retained for backwards compatibility
# Use "the {word} multipart body does not match the JSON file in {string}"
#
# Tests that the multipart payload body does not match a JSON file.
# JSON formatted multipart fields will be parsed into hashes.
#
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the multipart body does not match the JSON file in {string}') do |json_path|
  $logger.warn 'This step is deprecated and may be removed in a future release'
  step "the error multipart body does not match the JSON file in \"#{json_path}\""
end

# Tests that a given type of multipart payload body matches a JSON fixture.
# JSON formatted multipart fields will be parsed into hashes.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the {word} multipart body matches the JSON file in {string}') do |request_type, json_path|
  assert_true(File.exist?(json_path), "'#{json_path}' does not exist")
  payload_list = Maze::Server.list_for request_type
  raw_payload_value = payload_list.current[:body]
  payload_value = parse_multipart_body(raw_payload_value)
  expected_value = JSON.parse(open(json_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# (Deprecated) Retained for backwards compatibility
# Use "the {word} multipart body matches the JSON file in {string}"
#
# Tests that the multipart payload body matches a JSON fixture.
# JSON formatted multipart fields will be parsed into hashes.
#
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the multipart body matches the JSON file in {string}') do |json_path|
  $logger.warn 'This step is deprecated and may be removed in a future release'
  step "the error multipart body matches the JSON file in \"#{json_path}\""
end

# Tests that a given type of multipart field matches a JSON fixture.
# The field will be parsed into a hash.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the {word} multipart field {string} matches the JSON file in {string}') do |request_type, field_path, json_path|
  assert_true(File.exist?(json_path), "'#{json_path}' does not exist")
  payload_list = Maze::Server.list_for request_type
  payload_value = JSON.parse(payload_list.current[:body][field_path].to_s)
  expected_value = JSON.parse(open(json_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  assert_true(result.equal?, "The multipart field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# (Deprecated) Retained for backwards compatibility
# Use "the {word} multipart field {string} matches the JSON file in {string}"
#
# Tests that a multipart field matches a JSON fixture.
# The field will be parsed into a hash.
#
# @step_input field_path [String] Path to the tested element
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the multipart field {string} matches the JSON file in {string}') do |field_path, json_path|
  $logger.warn 'This step is deprecated and may be removed in a future release'
  step "the error multipart field \"#{field_path}\" matches the JSON file in \"#{json_path}\""
end

# Tests that a multipart request field exists and is not null.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input part_key [String] The key to the multipart element
Then('the field {string} for multipart {word} is not null') do |part_key, request_type|
  parts = Maze::Server.list_for(request_type).current[:body]
  assert_not_nil(parts[part_key], "The field '#{part_key}' should not be null")
end

# Tests that a multipart request field exists and is null.
#
# @step_input part_key [String] The key to the multipart element
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('the field {string} for multipart {word} is null') do |part_key, request_type|
  parts = Maze::Server.list_for(request_type).current[:body]
  assert_nil(parts[part_key], "The field '#{part_key}' should be null")
end

# Tests that a multipart request field equals a string.
#
# @step_input part_key [String] The key to the multipart element
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input expected_value [String] The string to match against
Then('the field {string} for multipart {word} equals {string}') do |part_key, request_type, expected_value|
  parts = Maze::Server.list_for(request_type).current[:body]
  assert_equal(parts[part_key], expected_value)
end
