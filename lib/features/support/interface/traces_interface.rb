# frozen_string_literal: true

# Turns off timestamp validation for tests where this cannot be checked correctly
def disable_timestamp_validation
  Maze.config.span_timestamp_validation = false
end

# Assert a specific amount of spans have been received
#
# @param min [Integer] The minimum spans desired
# @param max [Integer|nil] The maximum spans desired
def assert_received_span_count(min, max=nil)
  received_span_count = Maze::Accessors::TraceAccessors.received_span_count('trace', min)

  unless received_span_count >= min
    raise Test::Unit::AssertionFailedError.new <<-MESSAGE
    Expected #{min} spans but received #{received_span_count} within the #{Maze.config.receive_requests_wait}s timeout.
    This could indicate that:
    - Bugsnag crashed with a fatal error.
    - Bugsnag did not make the requests that it should have done.
    - The requests were made, but not deemed to be valid (e.g. missing integrity header).
    - The requests made were prevented from being received due to a network or other infrastructure issue.
    Please check the Maze Runner and device logs to confirm.)
    MESSAGE
  end

  Maze.check.operator(max, :>=, received_span_count, "#{received_span_count} spans received") if max
end

# Asserts an attribute in a specific field exists, and has a given type and value if appropriate
#
# @param field [String] The field to search for the attribute
# @param attribute [String] The name of the attribute
# @param attr_type [String|nil] The type of the attribute
# @param expected_value [Value|nil] The expected value to match
def assert_field_attribute_exists(field, attribute, attr_type=nil, expected_value=nil)
  found_attribute = Maze::Accessors::TraceAccessors.attribute_by_key('trace', field, attribute)

  Maze.check.not_nil(found_attribute, "Expected attribute '#{attribute}' in field '#{field}' not found")

  if attr_type && expected_value
    attribute_value = found_attribute['value']
    match = Maze::Accessors::TraceAccessors.attribute_value_matches?(attribute_value, attr_type, expected_value)

    Maze.check.true(match, "Expected attribute with type '#{attr_type}' and value '#{expected_value}', found '#{attribute_value}'")
  end
end

# Asserts an integer value of an attribute relates to a given value
#
# @param field [String] The field to search for the attribute
# @param attribute [String] The name of the attribute
# @param expected_value [Integer] The expected value to match
# @param operator [Symbol] The operator to use when comparing
def assert_field_attribute_integer_compares(field, attribute, expected_value, operator)
  found_attribute = Maze::Accessors::TraceAccessors.attribute_by_key('trace', field, attribute)

  Maze.check.not_nil(found_attribute, "Expected attribute #{attribute} in field #{field} not found")
  Maze.check.include(found_attribute['value'], 'intValue', "Payload field '#{field}' attribute '#{attribute}' value was not an 'intValue', found '#{found_attribute['value']}'")

  attribute_value = found_attribute['value']['intValue']
  failure_message = "The payload field '#{field}' attribute '#{attribute}' (#{attribute_value}) is not '#{operator}' than '#{expected_value}'"
  Maze.check.operator(attribute_value, operator, expected_value, failure_message)
end

# Asserts an attribute value with a given type matches a regex
#
# @param field [String] The field to search for the attribute
# @param attribute [String] The name of the attribute
# @param attr_type [String] The type of the attribute
# @param pattern [String] The regex to match against
def assert_field_attribute_matches_regex(field, attribute, attr_type, pattern)
  found_attribute = Maze::Accessors::TraceAccessors.attribute_by_key('trace', field, attribute)

  Maze.check.not_nil(found_attribute, "Expected attribute #{attribute} in field #{field} not found")
  Maze.check.include(found_attribute['value'], attr_type, "Payload field '#{field}' attribute '#{attribute}' value was not an '#{attr_type}', found '#{found_attribute['value']}'")

  attribute_value = found_attribute['value'][attr_type]
  failure_message = "The payload field '#{field}' attribute '#{attribute}' (#{attribute_value}) did not match the regex '#{pattern}'"
  regex = Regexp.new(pattern)
  Maze.check.match(regex, attribute_value, failure_message)
end

# Asserts an attribute value with a given type matches one of a list of possible values
#
# @param field [String] The field to search for the attribute
# @param attribute [String] The name of the attribute
# @param attr_type [String] The type of the attribute
# @param values [Array] The list of allowable values
def assert_field_attribute_one_of(field, attribute, attr_type, values)
  found_attribute = Maze::Accessors::TraceAccessors.attribute_by_key('trace', field, attribute)

  Maze.check.not_nil(found_attribute, "Expected attribute #{attribute} in field #{field} not found")
  Maze.check.include(found_attribute['value'], attr_type, "Payload field '#{field}' attribute '#{attribute}' value was not an '#{attr_type}', found '#{found_attribute['value']}'")

  attribute_value = found_attribute['value'][attr_type]
  allowable_values = values.raw.flatten
  failure_message = "The payload field '#{field}' attribute '#{attribute}' (#{attribute_value}) was not one of: '#{allowable_values}'"
  Maze.check.include(allowable_values, attribute_value, failure_message)
end


