# frozen_string_literal: true

# @!group Feature flag steps

# Verifies that there are no feature flags present in a given event
#
# @step_input event_id [Integer] The id of the event in the payloads array
Then('event {int} has no feature flags') do |event_id|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  assert_false(has_feature_flags?(event), "Feature flags expected to be absent or empty, was #{event['featureFlags']}")
end

# Verifies that the are no feature flags present
Then('the event has no feature flags') do
  steps %(
    Then event 0 has no feature flags
  )
end

# Verifies a feature flag with a specific variant is uniquely present in a givent even
#
# @step_input event_id [Integer] The id of the event in the payloads array
# @step_input flag_name [String] The featureFlag value expected
# @step_input variant [String] The variant value expected
Then('event {int} contains the feature flag {string} with variant {string}') do |event_id, flag_name, variant|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  assert(has_feature_flags?(event), "Expected feature flags were not present in event #{event_id}: #{event}")
  feature_flags = event['featureFlags']
  assert(
    feature_flags.one? { |flag| flag['featureFlag'] == flag_name && flag['variant'] == variant },
    "Feature flag: #{flag_name} with variant: #{variant} not found. Present flags: #{feature_flags}"
  )
end

# Verifies a feature flag with a specific variant is uniquely present
#
# @step_input flag_name [String] The featureFlag value expected
# @step_input variant [String] The variant value expected
Then('the event contains the feature flag {string} with variant {string}') do |flag_name, variant|
  steps %(
    Then event 0 contains the feature flag #{flag_name} with variant #{variant}
  )
end

# Verifies a feature flag with no variant (either null or missing) is uniquely present in a given event
#
# @step_input event_id [Integer] The id of the event in the payloads array
# @step_input flag_name [String] The featureFlag value expected
Then('event {int} contains the feature flag {string} with no variant') do |event_id, flag_name|
  event = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event_id}")
  assert(has_feature_flags?(event), "Expected feature flags were not present in event #{event_id}: #{event}")
  feature_flags = event['featureFlags']
  assert(
    feature_flags.one? { |flag| flag['featureFlag'] == flag_name && !flag.has_key?('variant') },
    "Feature flag: #{flag_name} was present with a variant in: #{feature_flags}"
  )
end

# Verifies a feature flag with no variant (either null or missing) is uniquely present
#
# @step_input flag_name [String] The featureFlag value expected
Then('the event contains the feature flag {string} with no variant') do |flag_name|
  steps %(
    Then event 0 contains the feature flag #{flag_name} with no variant
  )
end

# Verifies that a number of feature flags outlined in a table are all present and unique in the given event
#
# The DataTable used for this step should have `featureFlag` and `variant` columns, containing the appropriate
# values.  For missing or `null` variants, leave the `variant` column blank.
#
# Example:
#   | featureFlag | variant |
#   | my_flag_1   | var_1   |
#   | my_flag_2   | var_2   |
#   | my_flag_3   |         | # Variant expected is nil
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
  assert(has_feature_flags?(event), "Expected feature flags were not present in event #{event_id}: #{event}")
  feature_flags = event['featureFlags']
  assert(feature_flags.none? { |flag| flag['featureFlag'] == flag_name})
end

# Verifies a feature flag a specific name is not present, regardless of variant
#
# @step_input flag_name [String] The featureFlag value not expected
Then('the event does not contain the feature flag {string}') do |flag_name|
  steps %(
    Then event 0 does not contain the feature flag #{flag_name}
  )
end

def verify_feature_flags_with_table(event, table)
  assert(has_feature_flags?(event), "Expected feature flags were not present in event #{event_id}: #{event}")
  feature_flags = event['featureFlags']

  expected_features = table.hashes
  assert(feature_flags.size == expected_features.size, "Expected #{expected_features.size} features, found #{feature_flags}")
  expected_features.each do |expected|
    if expected['variant'].nil? || expected['variant'].empty?
      assert(
        feature_flags.one? { |flag| flag['featureFlag'] == expected['featureFlag'] && !flag.has_key?('variant') },
        "Feature flag: #{flag_name} was present with a variant in: #{feature_flags}"
      )
    else
      assert(
        feature_flags.one? { |flag| flag['featureFlag'] == expected['featureFlag'] && flag['variant'] == expected['variant'] },
        "Feature flag: #{flag_name} with variant: #{variant} not found. Present flags: #{feature_flags}"
      )
    end
  end
end

def has_feature_flags?(event)
  if event.has_key?('featureFlags')
    assert_false(event['featureFlags'].nil?, 'The feature flags key was present, but null')
    event['featureFlags'].is_a?(Array) && !event['featureFlags'].empty?
  else
    false
  end
end
