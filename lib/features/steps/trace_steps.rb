# @!group Trace steps

Then('I enter unmanaged traces mode') do
  Maze.config.unmanaged_traces_mode = true
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

Then('the trace payload field {string} double attribute {string} equals {float}') do |field, attribute, expected|
  check_attribute_equal field, attribute, 'doubleValue', expected
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
    expected_value.to_f.eql?(attribute_value[expected_type].to_f)
  when 'boolValue'
    expected_value.eql?('true').eql?(attribute_value[expected_type])
  when 'arrayValue'
    expected_value == attribute_value[expected_type]['values']
  when 'kvlistValue'
    $logger.error('Span attribute validation does not currently support the "kvlistValue" type')
    false
  else
    $logger.error("An invalid attribute type was expected: '#{expected_type}'")
    false
  end
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