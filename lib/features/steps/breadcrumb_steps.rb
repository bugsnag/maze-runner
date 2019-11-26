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
