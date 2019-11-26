# @!group Breadcrumb steps

# Tests whether the first event entry contains a specific breadcrumb with a type and name.
#
# @step_input type [String] The expected breadcrumb's type
# @step_input name [String] The expected breadcrumb's name
Then("the event has a {string} breadcrumb named {string}") do |type, name|
  value = Server.current_request[:body]["events"].first["breadcrumbs"]
  found = false
  value.each do |crumb|
    if crumb["type"] == type and crumb["name"] == name then
      found = true
    end
  end
  fail("No breadcrumb matched: #{value}") unless found
end

# Tests whether the first event entry contains a specific breadcrumb with a type and message.
#
# @step_input type [String] The expected breadcrumb's type
# @step_input message [String] The expected breadcrumb's message
Then("the event has a {string} breadcrumb with message {string}") do |type, message|
  value = Server.current_request[:body]["events"].first["breadcrumbs"]
  found = false
  value.each do |crumb|
    if crumb["type"] == type and crumb["metaData"] and crumb["metaData"]["message"] == message then
      found = true
    end
  end
  fail("No breadcrumb matched: #{value}") unless found
end

# Tests whether the first event entry does not contain a breadcrumb with a specific type.
# Used for confirming filtering of breadcrumbs
#
# @step_input type [String] The type of breadcrumb is not expected to be present
Then("the event does not have a {string} breadcrumb") do |type|
  value = Server.current_request[:body]["events"].first["breadcrumbs"]
  found = false
  value.each do |crumb|
    if crumb["type"] == type
      found = true
    end
  end
  fail("Breadcrumb with type: #{type} matched") if found
end

# Tests whether any breadcrumb matches a given JSON fixture.  This follows all the usual rules for JSON fixture matching.
#
# @step_input json_fixture [String] A path to the JSON fixture to compare against
Then("the event contains a breadcrumb matching the JSON fixture in {string}") do |json_fixture|
  breadcrumbs = read_key_path(Server.current_request[:body], "events.0.breadcrumbs")
  expected = JSON.parse(open(json_fixture, &:read))
  match = breadcrumbs.any? { |breadcrumb| value_compare(expected, breadcrumb).equal? }
  assert(match, "No breadcrumbs in the event matched the given breadcrumb")
end
