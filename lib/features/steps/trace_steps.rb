# @!group Trace steps

# Waits for a given number of spans to be received, which may be spread across one or more trace requests.
#
# @step_input span_count [Integer] The number of spans to wait for
When('I wait for {int} span(s)') do |span_count|
  assert_received_spans span_count, Maze::Server.list_for('traces')
end

Then('I should have received no spans') do
  sleep Maze.config.receive_no_requests_wait
  Maze.check.equal spans_from_request_list(Maze::Server.list_for('traces')).size, 0
end

Then('the trace payload field {string} bool attribute {string} is true') do |field, attribute|
  check_attribute_equal field, attribute, 'boolValue', true
end

Then('the trace payload field {string} bool attribute {string} is false') do |field, attribute|
  check_attribute_equal field, attribute, 'boolValue', false
end

Then('the trace payload field {string} integer attribute {string} equals {int}') do |field, attribute, expected|
  check_attribute_equal field, attribute, 'intValue', expected
end

Then('the trace payload field {string} integer attribute {string} is greater than {int}') do |field, attribute, expected|
  value = get_attribute_value field, attribute, 'intValue'
  Maze.check.operator value, :>, expected,
                      "The payload field '#{field}' attribute '#{attribute}' (#{value}) is not greater than '#{expected}'"
end

Then('the trace payload field {string} string attribute {string} equals {string}') do |field, attribute, expected|
  check_attribute_equal field, attribute, 'stringValue', expected
end

Then('the trace payload field {string} string attribute {string} equals the stored value {string}') do |field, attribute, stored_key|
  value = get_attribute_value field, attribute, 'stringValue'
  stored = Maze::Store.values[stored_key]
  result = Maze::Compare.value value, stored
  Maze.check.true result.equal?, "Payload value: #{value} does not equal stored value: #{stored}"
end

Then('the trace payload field {string} string attribute {string} matches the regex {string}') do |field, attribute, pattern|
  value = get_attribute_value field, attribute, 'stringValue'
  regex = Regexp.new pattern
  Maze.check.match regex, value
end

Then('the trace payload field {string} integer attribute {string} matches the regex {string}') do |field, attribute, pattern|
  regex = Regexp.new(pattern)
  list = Maze::Server.traces
  attributes = Maze::Helper.read_key_path(list.current[:body], "#{field}.attributes")
  attribute = attributes.find { |a| a['key'] == attribute }
  value = attribute["value"]["intValue"]
  Maze.check.match(regex, value)
end

Then('the trace payload field {string} string attribute {string} exists') do |field, attribute|
  value = get_attribute_value field, attribute, 'stringValue'
  Maze.check.not_nil value
end

Then('the trace payload field {string} string attribute {string} is one of:') do |field, key, possible_values|
  list = Maze::Server.traces
  attributes = Maze::Helper.read_key_path(list.current[:body], "#{field}.attributes")
  attribute = attributes.find { |a| a['key'] == key }

  possible_attributes = possible_values.raw.flatten.map { |v| { 'key' => key, 'value' => { 'stringValue' => v } } }
  Maze.check.not_nil(attribute, "The attribute #{key} is nil")
  Maze.check.include(possible_attributes, attribute)
end

Then('the trace payload field {string} boolean attribute {string} is true') do |field, key|
  assert_attribute field, key, { 'boolValue' => true }
end

Then('the trace payload field {string} boolean attribute {string} is false') do |field, key|
  assert_attribute field, key, { 'boolValue' => false }
end

# @!group Span steps
Then('a span {word} equals {string}') do |attribute, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span[attribute] }
  Maze.check.includes selected_attributes, expected
end

Then('every span field {string} equals {string}') do |key, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_keys = spans.map { |span| span[key] == expected }
  Maze.check.not_includes selected_keys, false
end

Then('every span field {string} matches the regex {string}') do |key, pattern|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.match pattern, span[key] }
end

Then('every span string attribute {string} exists') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.not_nil span['attributes'].find { |a| a['key'] == attribute }['value']['stringValue'] }
end

Then('every span string attribute {string} equals {string}') do |attribute, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.equal expected, span['attributes'].find { |a| a['key'] == attribute }['value']['stringValue'] }
end

Then('every span string attribute {string} matches the regex {string}') do |attribute, pattern|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.match pattern, span['attributes'].find { |a| a['key'] == attribute }['value']['stringValue'] }
end

Then('every span integer attribute {string} is greater than {int}') do |attribute, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze::check.true span['attributes'].find { |a| a['key'] == attribute }['value']['intValue'].to_i > expected }
end

Then('every span bool attribute {string} is true') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze::check.true span['attributes'].find { |a| a['key'] == attribute }['value']['boolValue'] }
end

Then('a span string attribute {string} exists') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('stringValue') } }.compact
  Maze.check.false(selected_attributes.empty?)
end

Then('a span string attribute {string} equals {string}') do |attribute, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('stringValue') } }.compact
  attribute_values = selected_attributes.map { |a| a['value']['stringValue'] }
  Maze.check.includes attribute_values, expected
end

Then('a span field {string} equals {string}') do |key, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_keys = spans.map { |span| span[key] }
  Maze.check.includes selected_keys, expected
end

Then('a span field {string} equals {int}') do |key, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_keys = spans.map { |span| span[key] }
  Maze.check.includes selected_keys, expected
end

Then('a span field {string} matches the regex {string}') do |attribute, pattern|
  regex = Regexp.new pattern
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.select { |span| regex.match? span[attribute] }

  Maze.check.false(selected_attributes.empty?)
end

Then('a span named {string} contains the attributes:') do |span_name, table|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  named_spans = spans.find_all { |span| span['name'].eql?(span_name) }
  raise Test::Unit::AssertionFailedError.new "No spans were found with the name #{span_name}" if named_spans.empty?

  expected_attributes = table.hashes

  match = false
  named_spans.each do |span|
    matches = expected_attributes.map do |expected_attribute|
      span['attributes'].find_all { |attribute| attribute['key'].eql?(expected_attribute['attribute']) }
        .any? { |attribute| attribute_value_matches?(attribute['value'], expected_attribute['type'], expected_attribute['value']) }
    end
    if matches.all? && !matches.empty?
      match = true
      break
    end
  end

  unless match
    raise Test::Unit::AssertionFailedError.new "No spans were found containing all of the given attributes"
  end
end

Then('a span named {string} has a parent named {string}') do |child_name, parent_name|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  child_spans = spans.find_all { |span| span['name'].eql?(child_name) }
  raise Test::Unit::AssertionFailedError.new "No spans were found with the name #{child_name}" if child_spans.empty?
  parent_spans = spans.find_all { |span| span['name'].eql?(parent_name) }
  raise Test::Unit::AssertionFailedError.new "No spans were found with the name #{parent_name}" if parent_spans.empty?

  expected_parent_ids = child_spans.map { |span| span['parentSpanId'] }
  parent_ids = parent_spans.map { |span| span['spanId'] }
  match = expected_parent_ids.any? { |expected_id| parent_ids.include?(expected_id) }

  unless match
    raise Test::Unit::AssertionFailedError.new "No child span named #{child_name} was found with a parent named #{parent_name}"
  end
end

def spans_from_request_list list
  return list.remaining
             .flat_map { |req| req[:body]['resourceSpans'] }
             .flat_map { |r| r['scopeSpans'] }
             .flat_map { |s| s['spans'] }
             .select { |s| !s.nil? }
end

def attribute_value_matches?(attribute_value, expected_type, expected_value)
  # Check that the required value type key is present
  unless attribute_value.keys.include?(expected_type)
    return false
  end

  case expected_type
  when 'bytesValue', 'stringValue'
    expected_value.eql?(attribute_value[expected_type])
  when 'intValue'
    expected_value.to_i.eql?(attribute_value[expected_type].to_i)
  when 'doubleValue'
    expected_value.to_f.eql?(attribute_value[expected_type])
  when 'boolValue'
    expected_value.eql?('true').eql?(attribute_value[expected_type])
  when 'arrayValue', 'kvlistValue'
    $logger.error('Span attribute validation does not currently support the "arrayValue" or "kvlistValue" types')
    false
  else
    $logger.error("An invalid attribute type was expected: '#{expected_type}'")
    false
  end
end

def assert_received_spans(span_count, list)
  timeout = Maze.config.receive_requests_wait
  wait = Maze::Wait.new(timeout: timeout)

  received = wait.until { spans_from_request_list(list).size >= span_count }
  received_count = spans_from_request_list(list).size

  unless received
    raise Test::Unit::AssertionFailedError.new <<-MESSAGE
    Expected #{span_count} spans but received #{received_count} within the #{timeout}s timeout.
    This could indicate that:
    - Bugsnag crashed with a fatal error.
    - Bugsnag did not make the requests that it should have done.
    - The requests were made, but not deemed to be valid (e.g. missing integrity header).
    - The requests made were prevented from being received due to a network or other infrastructure issue.
    Please check the Maze Runner and device logs to confirm.)
    MESSAGE
  end

  Maze.check.operator(span_count, :<=, received_count, "#{received_count} spans received")

  Maze::Schemas::Validator.verify_against_schema(list, 'trace')
  Maze::Schemas::Validator.validate_payload_elements(list, 'trace')
end

def get_attribute_value(field, attribute, attr_type)
  list = Maze::Server.list_for 'trace'
  attributes = Maze::Helper.read_key_path list.current[:body], "#{field}.attributes"
  attribute = attributes.find { |a| a['key'] == attribute }
  value = attribute&.dig 'value', attr_type
  attr_type == 'intValue' && value.is_a?(String) ? value.to_i : value
end

def check_attribute_equal(field, attribute, attr_type, expected)
  actual = get_attribute_value field, attribute, attr_type
  Maze.check.equal(expected, actual)
end

def assert_attribute(field, key, expected)
  list = Maze::Server.traces
  attributes = Maze::Helper.read_key_path(list.current[:body], "#{field}.attributes")
  Maze.check.equal({ 'key' => key, 'value' => expected }, attributes.find { |a| a['key'] == key })
end
