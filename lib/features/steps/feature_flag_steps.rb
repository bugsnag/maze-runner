# frozen_string_literal: true

# @!group Feature flag steps

# Verifies that the are no feature flags present
Then('the event has no feature flags') do
  featureFlags = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.0.featureFlags")
  assert(featureFlags.nil? || featureFlags.empty?, "Feature flags expected to be nil or empty, was #{featureFlags}")
end

# Verifies a feature flag with a specific variant is uniquely present
#
# @step_input flag_name [String] The featureFlag value expected
# @step_input variant [String] The variant value expected
Then('the event contains the feature flag {string} with variant {string}') do |flag_name, variant|
  featureFlags = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.0.featureFlags")
  assert_false(featureFlags.nil? || featureFlags.empty?, "Feature flags were nil or empty: #{featureFlags}")
  assert(featureFlags.one? { |flag| flag['featureFlag'] == flag_name && flag['variant'] == variant })
end

# Verifies a feature flag with no variant (either null or missing) is uniquely present
#
# @step_input flag_name [String] The featureFlag value expected
Then('the event contains the feature flag {string} with no variant') do |flag_name|
  featureFlags = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.0.featureFlags")
  assert_false(featureFlags.nil? || featureFlags.empty?, "Feature flags were nil or empty: #{featureFlags}")
  assert(featureFlags.one? { |flag| flag['featureFlag'] == flag_name && flag['variant'].nil? })
end

# Verifies that a number of feature flags outlined in a table are all present and unique
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
# @step_input table [Cucumber::MultilineArgument::DataTable] Table of expected values
Then('the event contains the following feature flags:') do |table|
  featureFlags = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.0.featureFlags")
  assert_false(featureFlags.nil? || featureFlags.empty?, "Feature flags were nil or empty: #{featureFlags}")

  expected_features = table.hashes
  assert(featureFlags.size == expected_features.size, "Expected #{expected_features.size} features, found #{featureFlags.size}")
  expected_features.each do |expected|
    if expected['variant'].nil? || expected['variant'].empty?
      assert(featureFlags.one? { |flag| flag['featureFlag'] == expected['featureFlag'] && flag['variant'].nil?})
    else
      assert(featureFlags.one? { |flag| flag['featureFlag'] == expected['featureFlag'] && flag['variant'] == expected['variant']})
    end
  end
end

# Verifies a feature flag a specific name is not present, regardless of variant
#
# @step_input flag_name [String] The featureFlag value not expected
Then('the event does not contain the feature flag {string}') do |flag_name|
  featureFlags = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.0.featureFlags")
  assert_false(featureFlags.nil? || featureFlags.empty?, "Feature flags were nil or empty: #{featureFlags}")
  assert(featureFlags.none? { |flag| flag['featureFlag'] == flag_name})
end
