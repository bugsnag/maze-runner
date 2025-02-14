# @!group Trace steps

# Disable timestamp validation for spans
#
When('I disable timestamp validation for spans') do
  disable_timestamp_validation
end

# Waits for a given number of spans to be received, which may be spread across one or more trace requests.
#
# @step_input span_count [Integer] The number of spans to wait for
Then('I wait to receive {int} span(s)') do |span_count|
  assert_received_span_count(span_count, span_count)
end

# Waits for a minimum number of spans to be received, which may be spread across one or more trace requests.
# If more spans than requested are received, this step will still pass.
#
# @step_input span_min [Integer] The minimum number of spans to wait for
 Then('I wait to receive at least {int} span(s)') do |span_min|
  assert_received_span_count(span_min)
end

# Waits for a minimum number of spans to be received, which may be spread across one or more trace requests.
# If more spans than the maximum requested number of spans are received, this step will fail.
#
# @step_input span_min [Integer] The minimum number of spans to wait for
# @step_input span_max [Integer] The maximum number of spans to receive before failure
Then('I wait to receive between {int} and {int} span(s)') do |span_min, span_max|
  assert_received_span_count(span_min, span_max)
end

Then('I should have received no spans') do
  sleep Maze.config.receive_no_requests_wait
  Maze.check.equal Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces')).size, 0
end

Then('I enter unmanaged traces mode') do
  Maze.config.unmanaged_traces_mode = true
end

Then('the trace payload field {string} bool attribute {string} is true') do |field, attribute|
  assert_field_attribute_exists(field, attribute, 'boolValue', true)
end

Then('the trace payload field {string} boolean attribute {string} is true') do |field, key|
  assert_field_attribute_exists(field, attribute, 'boolValue', true)
end

Then('the trace payload field {string} bool attribute {string} is false') do |field, attribute|
  assert_field_attribute_exists(field, attribute, 'boolValue', false)
end

Then('the trace payload field {string} boolean attribute {string} is false') do |field, key|
  assert_field_attribute_exists(field, attribute, 'boolValue', false)
end

Then('the trace payload field {string} integer attribute {string} equals {int}') do |field, attribute, expected|
  assert_field_attribute_exists(field, attribute, 'intValue', expected)
end

Then('the trace payload field {string} integer attribute {string} is greater than {int}') do |field, attribute, expected|
  assert_field_attribute_integer_compares(field, attribute, expected, :>)
end

Then('the trace payload field {string} string attribute {string} equals {string}') do |field, attribute, expected|
  assert_field_attribute_exists(field, attribute, 'stringValue', expected)
end

Then('the trace payload field {string} string attribute {string} equals the stored value {string}') do |field, attribute, stored_key|
  stored = Maze::Store.values[stored_key]
  assert_field_attribute_exists(field, attribute, 'stringValue', stored)
end

Then('the trace payload field {string} double attribute {string} equals {float}') do |field, attribute, expected|
  assert_field_attribute_exists(field, attribute, 'doubleValue', expected)
end

Then('the trace payload field {string} string attribute {string} matches the regex {string}') do |field, attribute, pattern|
  assert_field_attribute_matches_regex(field, attribute, 'stringValue', pattern)
end

Then('the trace payload field {string} integer attribute {string} matches the regex {string}') do |field, attribute, pattern|
  assert_field_attribute_matches_regex(field, attribute, 'intValue', pattern)
end

Then('the trace payload field {string} string attribute {string} exists') do |field, attribute|
  assert_field_attribute_exists(field, attribute, 'stringValue')
end

Then('the trace payload field {string} string attribute {string} is one of:') do |field, attribute, possible_values|
  assert_field_attribute_one_of(field, attribute, 'stringValue', possible_values)
end

# @!group Span steps
Then('a span {word} equals {string}') do |attribute, expected|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span[attribute] }
  Maze.check.includes selected_attributes, expected
end

Then('every span field {string} equals {string}') do |key, expected|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  selected_keys = spans.map { |span| span[key] == expected }
  Maze.check.not_includes selected_keys, false
end

Then('every span field {string} matches the regex {string}') do |key, pattern|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.match pattern, span[key] }
end

Then('every span string attribute {string} exists') do |attribute|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.not_nil span['attributes'].find { |a| a['key'] == attribute }['value']['stringValue'] }
end

Then('every span string attribute {string} equals {string}') do |attribute, expected|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.equal expected, span['attributes'].find { |a| a['key'] == attribute }['value']['stringValue'] }
end

Then('every span string attribute {string} matches the regex {string}') do |attribute, pattern|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.match pattern, span['attributes'].find { |a| a['key'] == attribute }['value']['stringValue'] }
end

Then('every span integer attribute {string} is greater than {int}') do |attribute, expected|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze::check.true span['attributes'].find { |a| a['key'] == attribute }['value']['intValue'].to_i > expected }
end

Then('every span bool attribute {string} is true') do |attribute|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze::check.true span['attributes'].find { |a| a['key'] == attribute }['value']['boolValue'] }
end

Then('a span string attribute {string} exists') do |attribute|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('stringValue') } }.compact
  Maze.check.false(selected_attributes.empty?)
end

Then('a span string attribute {string} equals {string}') do |attribute, expected|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('stringValue') } }.compact
  attribute_values = selected_attributes.map { |a| a['value']['stringValue'] }
  Maze.check.includes attribute_values, expected
end

Then('a span field {string} equals {string}') do |key, expected|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  selected_keys = spans.map { |span| span[key] }
  Maze.check.includes selected_keys, expected
end

Then('a span field {string} equals {int}') do |key, expected|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  selected_keys = spans.map { |span| span[key] }
  Maze.check.includes selected_keys, expected
end

Then('a span field {string} matches the regex {string}') do |attribute, pattern|
  regex = Regexp.new pattern
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.select { |span| regex.match? span[attribute] }

  Maze.check.false(selected_attributes.empty?)
end

Then('a span named {string} contains the attributes:') do |span_name, table|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
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
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
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

Then('a span named {string} has the following properties:') do |span_name, table|
  spans = Maze::Accessors::TraceAccessors.spans_from_request_list(Maze::Server.list_for('traces'))
  found_spans = spans.find_all { |span| span['name'].eql?(span_name) }
  raise Test::Unit::AssertionFailedError.new "No spans were found with the name #{span_name}" if found_spans.empty?

  expected_properties = table.hashes

  match = false
  found_spans.each do |span|
    matches = expected_properties.map do |expected_property|
      property = Maze::Helper.read_key_path(span, expected_property['property'])
      expected_property['value'].eql?(property.to_s)
    end
    if matches.all? && !matches.empty?
      match = true
      break
    end
  end

  unless match
    raise Test::Unit::AssertionFailedError.new "No spans were found containing all of the given properties"
  end
end

def check_array_attribute_equal(field, attribute, expected_values)
  actual_values = get_attribute_value(field, attribute, 'arrayValue')['values']

  # Convert string representations of integers to integers for comparison
  actual_values.map! do |value|
    if value.key?('intValue')
      value['intValue'].to_i
    else
      value
    end
  end

  expected_values.map! do |value|
    if value.key?('intValue')
      value['intValue'].to_i
    else
      value
    end
  end

  Maze.check.equal(expected_values, actual_values)
end

Then('the trace payload field {string} string array attribute {string} equals the array:') do |field, attribute, expected_values|
  expected_values_list = expected_values.raw.flatten.map { |v| { 'stringValue' => v } }
  check_array_attribute_equal field, attribute, expected_values_list
end

Then('the trace payload field {string} integer array attribute {string} equals the array:') do |field, attribute, expected_values|
  expected_values_list = expected_values.raw.flatten.map { |v| { 'intValue' => v.to_i } }
  check_array_attribute_equal(field, attribute, expected_values_list)
end

Then('the trace payload field {string} double array attribute {string} equals the array:') do |field, attribute, expected_values|
  expected_values_list = expected_values.raw.flatten.map { |v| { 'doubleValue' => v.to_f } }
  check_array_attribute_equal field, attribute, expected_values_list
end

Then('the trace payload field {string} boolean array attribute {string} equals the array:') do |field, attribute, expected_values|
  expected_values_list = expected_values.raw.flatten.map { |v| { 'boolValue' => v == 'true' } }
  check_array_attribute_equal field, attribute, expected_values_list
end