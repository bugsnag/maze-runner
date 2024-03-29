# frozen_string_literal: true

# @!group Feature flag steps

# Verifies that there are no feature flags present in a given event
#
# @step_input event_id [Integer] The id of the event in the payloads array
Then('event {int} has no feature flags') do |event_id|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  Maze.check.false(has_feature_flags?(event), "Feature flags expected to be absent or empty, was #{event['featureFlags']}")
end

# Verifies that the are no feature flags present
Then('the event has no feature flags') do
  steps %(
    Then event 0 has no feature flags
  )
end

# Verifies a feature flag with a specific variant is uniquely present in a given event
#
# @step_input event_id [Integer] The id of the event in the payloads array
# @step_input flag_name [String] The featureFlag value expected
# @step_input variant [String] The variant value expected
Then('event {int} contains the feature flag {string} with variant {string}') do |event_id, flag_name, variant|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  Maze.check.true(has_feature_flags?(event), "Expected feature flags were not present in event #{event_id}: #{event}")
  feature_flags = event['featureFlags']
  # Test for flag name uniqueness
  Maze.check.true(
    feature_flags.one? { |flag| flag['featureFlag'].eql?(flag_name) },
    "Expected single flag with 'featureFlag' value: #{flag_name}. Present flags: #{feature_flags}"
  )

  flag = feature_flags.find { |flag| flag['featureFlag'].eql?(flag_name) }
  # Test the variant value
  Maze.check.true(
    flag.has_key?('variant') && flag['variant'].eql?(variant),
    "Feature flag: #{flag} did not have variant: #{variant}. All flags: #{feature_flags}"
  )
end

# Verifies a feature flag with a specific variant is uniquely present
#
# @step_input flag_name [String] The featureFlag value expected
# @step_input variant [String] The variant value expected
Then('the event contains the feature flag {string} with variant {string}') do |flag_name, variant|
  steps %(
    Then event 0 contains the feature flag "#{flag_name}" with variant "#{variant}"
  )
end

# Verifies a feature flag with no variant (either null or missing) is uniquely present in a given event
#
# @step_input event_id [Integer] The id of the event in the payloads array
# @step_input flag_name [String] The featureFlag value expected
Then('event {int} contains the feature flag {string} with no variant') do |event_id, flag_name|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  Maze.check.true(has_feature_flags?(event),
                  "Expected feature flags were not present in event #{event_id}: #{event}")
  feature_flags = event['featureFlags']
  # Test for flag name uniqueness
  Maze.check.true(
    feature_flags.one? { |flag| flag['featureFlag'].eql?(flag_name) },
    "Expected single flag with 'featureFlag' value: #{flag_name}. All flags: #{feature_flags}"
  )

  flag = feature_flags.find { |flag| flag['featureFlag'].eql?(flag_name) }
  # Test the variant value
  Maze.check.false(
    flag.has_key?('variant'),
    "Feature flag: #{flag} expected to have no variant. All flags: #{feature_flags}"
  )
end

# Verifies a feature flag with no variant (either null or missing) is uniquely present
#
# @step_input flag_name [String] The featureFlag value expected
Then('the event contains the feature flag {string} with no variant') do |flag_name|
  steps %(
    Then event 0 contains the feature flag "#{flag_name}" with no variant
  )
end

# Verifies that a number of feature flags outlined in a table are all present and unique in the given event
#
# The DataTable used for this step should have `featureFlag` and `variant` columns, containing the appropriate
# values.  For flags with a variant leave the `variant` column blank.
#
# Example:
#   | featureFlag | variant |
#   | my_flag_1   | var_1   |
#   | my_flag_2   | var_2   |
#   | my_flag_3   |         | # Should not have a variant present
#
# @step_input event_id [Integer] The id of the event in the payloads array
# @step_input table [Cucumber::MultilineArgument::DataTable] Table of expected values
Then('event {int} contains the following feature flags:') do |event_id, table|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  verify_feature_flags_with_table(event, table)
end

# Verifies that a number of feature flags outlined in a table are all present and unique
#
# See above for data table details
#
# @step_input table [Cucumber::MultilineArgument::DataTable] Table of expected values
Then('the event contains the following feature flags:') do |table|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], 'events.0')
  verify_feature_flags_with_table(event, table)
end

# Verifies a feature flag a specific name is not present, regardless of variant, for a given event
#
# @step_input event_id [Integer] The id of the event in the payloads array
# @step_input flag_name [String] The featureFlag value not expected
Then('event {int} does not contain the feature flag {string}') do |event_id, flag_name|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  Maze.check.true(
    has_feature_flags?(event),
    "Expected feature flags were not present in event #{event_id}: #{event}"
  )
  feature_flags = event['featureFlags']
  Maze.check.true(
    feature_flags.none? { |flag| flag['featureFlag'].eql?(flag_name) },
    "Expected to not find feature flag #{flag_name}.  All flags: #{feature_flags}"
  )
end

# Verifies a feature flag a specific name is not present, regardless of variant
#
# @step_input flag_name [String] The featureFlag value not expected
Then('the event does not contain the feature flag {string}') do |flag_name|
  steps %(
    Then event 0 does not contain the feature flag "#{flag_name}"
  )
end

def verify_feature_flags_with_table(event, table)
  Maze.check.true(
    has_feature_flags?(event),
    "Expected feature flags were not present in event: #{event}"
  )
  feature_flags = event['featureFlags']

  expected_features = table.hashes
  Maze.check.true(
    feature_flags.size == expected_features.size,
    "Expected #{expected_features.size} features,
    found #{feature_flags}"
  )
  expected_features.each do |expected|
    flag_name = expected['featureFlag']
    variant = expected['variant']
    # Test for flag name uniqueness
    Maze.check.true(
      feature_flags.one? { |flag| flag['featureFlag'].eql?(flag_name) },
      "Expected single flag with 'featureFlag' value: #{flag_name}. Present flags: #{feature_flags}"
    )
    flag = feature_flags.find { |flag| flag['featureFlag'].eql?(flag_name) }
    # Test the variant value
    if variant.nil? || expected['variant'].empty?
      Maze.check.false(
        flag.has_key?('variant'),
        "Feature flag: #{flag} expected to have no variant. All flags: #{feature_flags}"
      )
    else
      Maze.check.true(
        flag.has_key?('variant') && flag['variant'].eql?(variant),
        "Feature flag: #{flag} did not have variant: #{variant}. All flags: #{feature_flags}"
      )
    end
  end
end

def has_feature_flags?(event)
  if event.has_key?('featureFlags')
    Maze.check.false(
      event['featureFlags'].nil?,
      'The feature flags key was present, but null'
    )
    Maze.check.true(
      event['featureFlags'].is_a?(Array),
      "The feature flags key was present, but the value: #{event['featureFlags']} must be an array"
    )
    !event['featureFlags'].empty?
  else
    false
  end
end
