require 'test/unit'
require 'open-uri'
require 'json'
require 'cgi'

# @!group Multipart request assertion steps

# Verifies a request contains the correct Content-Type header and some contents
# for a multipart/form-data request
#
# @param request [Hash] The payload to test
def valid_multipart_form_data?(request)
  content_regex = Regexp.new('^multipart\\/form-data; boundary=[\\h-]+$')
  content_header = request[:request]['Content-Type']
  Maze.check.match(content_regex, content_header)
  Maze.check.true(
    request[:body].size.positive?,
    "Multipart request payload contained #{request[:body].size} fields"
  )
end

# Verifies that any type of request contains multipart form-data
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('the {request_type} request is valid multipart form-data') do |request_type|
  list = Maze::Server.list_for request_type
  valid_multipart_form_data?(list.current)
end

# Verifies all requests of a given type contain multipart form-data
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('all {request_type} requests are valid multipart form-data') do |request_type|
  list = Maze::Server.list_for request_type
  list.all.all? { |request| valid_multipart_form_data?(request) }
end

# Tests the number of fields a given type of multipart request contains.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input part_count [Integer] The number of expected fields
Then('the {request_type} multipart request has {int} fields') do |request_type, part_count|
  list = Maze::Server.list_for request_type
  parts = list.current[:body]
  Maze.check.equal(part_count, parts.size)
end

# Tests a given type of multipart request has at least one field.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('the {request_type} multipart request has a non-empty body') do |request_type|
  list = Maze::Server.list_for request_type
  parts = list.current[:body]
  Maze.check.true(parts.size.positive?, "Multipart request payload contained #{parts.size} fields")
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
Then('the {request_type} multipart body does not match the JSON file in {string}') do |request_type, json_path|
  Maze.check.true(File.exist?(json_path), "'#{json_path}' does not exist")
  payload_list = Maze::Server.list_for request_type
  raw_payload_value = payload_list.current[:body]
  payload_value = parse_multipart_body(raw_payload_value)
  expected_value = JSON.parse(open(json_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  Maze.check.false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end

# Tests that a given type of multipart payload body matches a JSON fixture.
# JSON formatted multipart fields will be parsed into hashes.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the {request_type} multipart body matches the JSON file in {string}') do |request_type, json_path|
  Maze.check.true(File.exist?(json_path), "'#{json_path}' does not exist")
  payload_list = Maze::Server.list_for request_type
  raw_payload_value = payload_list.current[:body]
  payload_value = parse_multipart_body(raw_payload_value)
  expected_value = JSON.parse(open(json_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  Maze.check.true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Tests that a given type of multipart field matches a JSON fixture.
# The field will be parsed into a hash.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
# @step_input json_path [String] Path to a JSON file relative to maze-runner root
Then('the {request_type} multipart field {string} matches the JSON file in {string}') do |request_type, field_path, json_path|
  Maze.check.true(File.exist?(json_path), "'#{json_path}' does not exist")
  payload_list = Maze::Server.list_for request_type
  payload_value = JSON.parse(payload_list.current[:body][field_path].to_s)
  expected_value = JSON.parse(open(json_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  Maze.check.true(result.equal?, "The multipart field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Tests that a multipart request field exists and is not null.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input part_key [String] The key to the multipart element
Then('the field {string} for multipart {request_type} is not null') do |part_key, request_type|
  parts = Maze::Server.list_for(request_type).current[:body]
  Maze.check.not_nil(parts[part_key], "The field '#{part_key}' should not be null")
end

# Tests that a multipart request field exists and is null.
#
# @step_input part_key [String] The key to the multipart element
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('the field {string} for multipart {request_type} is null') do |part_key, request_type|
  parts = Maze::Server.list_for(request_type).current[:body]
  Maze.check.nil(parts[part_key], "The field '#{part_key}' should be null")
end

# Tests that a multipart request field equals a string.
#
# @step_input part_key [String] The key to the multipart element
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input expected_value [String] The string to match against
Then('the field {string} for multipart {request_type} equals {string}') do |part_key, request_type, expected_value|
  parts = Maze::Server.list_for(request_type).current[:body]
  Maze.check.equal(parts[part_key], expected_value)
end
