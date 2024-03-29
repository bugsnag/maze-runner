# @!group Breadcrumb steps

# Tests whether the first event entry contains the specified number of breadcrumbs.
#
# @step_input expected [Integer] The expected number of breadcrumbs
Then("the event has {int} breadcrumb(s)") do |expected|
  breadcrumbs = Maze::Server.errors.current[:body]['events'].first['breadcrumbs']

  Maze.check.equal(
    expected,
    breadcrumbs&.length || 0,
    "Expected event to have '#{expected}' breadcrumbs, but got: #{breadcrumbs}"
  )
end

# Tests whether the first event entry contains no breadcrumbs.
Then("the event has no breadcrumbs") do
  breadcrumbs = Maze::Server.errors.current[:body]['events'].first['breadcrumbs']

  Maze.check.true(
    # some notifiers may omit breadcrumbs entirely when empty, otherwise it should
    # be an empty array
    breadcrumbs.nil? || breadcrumbs.empty?,
    "Expected event not to have breadcrumbs, but got: #{breadcrumbs}"
  )
end

# Tests whether the first event entry contains a specific breadcrumb with a type and name.
#
# @step_input type [String] The expected breadcrumb's type
# @step_input name [String] The expected breadcrumb's name
Then('the event has a {string} breadcrumb named {string}') do |type, name|
  breadcrumbs = Maze::Server.errors.current[:body]['events'].first['breadcrumbs']

  Maze.check.true(
    breadcrumbs.any? { |crumb| crumb['type'] == type && crumb['name'] == name },
    "Expected event to have a breadcrumb with type '#{type}' and name '#{name}', but got: #{breadcrumbs}"
  )
end

# Tests whether the first event entry contains a specific breadcrumb with a type and message.
#
# @step_input type [String] The expected breadcrumb's type
# @step_input message [String] The expected breadcrumb's message
Then('the event has a {string} breadcrumb with message {string}') do |type, message|
  value = Maze::Server.errors.current[:body]['events'].first['breadcrumbs']
  found = value.any? { |crumb| crumb['type'] == type && crumb['metaData'] && crumb['metaData']['message'] == message }
  raise("No breadcrumb matched: #{value}") unless found
end

# Tests whether the first event entry does not contain a breadcrumb with a specific type.
# Used for confirming filtering of breadcrumbs
#
# @step_input type [String] The type of breadcrumb expected to not be present
Then('the event does not have a {string} breadcrumb') do |type|
  value = Maze::Server.errors.current[:body]['events'].first['breadcrumbs']
  found = value.any? { |crumb| crumb['type'] == type  }
  raise("Breadcrumb with type: #{type} matched") if found
end

# Test whether the first event entry does not contain a breadcrumb with a specific type and message.
# Used for confirming filtering of breadcrumbs
#
# @step_input type [String] The type of the breadcrumb expected to be absent
# @step_input message [String] The message of the breadcrumb expected to be absent
Then('the event does not have a {string} breadcrumb with message {string}') do |type, message|
  value = Maze::Server.errors.current[:body]['events'].first['breadcrumbs']
  found = value.any? { |crumb| crumb['type'] == type && crumb['metaData'] && crumb['metaData']['message'] == message }
  raise("Breadcrumb with type: #{type} and message: #{message} matched") if found
end

# Tests whether any breadcrumb matches a given JSON fixture.  This follows all the usual rules for JSON fixture matching.
#
# @step_input json_fixture [String] A path to the JSON fixture to compare against
Then('the event contains a breadcrumb matching the JSON fixture in {string}') do |json_fixture|
  breadcrumbs = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], 'events.0.breadcrumbs')
  expected = JSON.parse(File.open(json_fixture, &:read))
  match = breadcrumbs.any? { |breadcrumb| Maze::Compare.value(expected, breadcrumb).equal? }
  Maze.check.true(match, 'No breadcrumbs in the event matched the given breadcrumb')
end
