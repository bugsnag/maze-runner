When('I ignore invalid {request_type}') do |type|
  Maze.config.captured_invalid_requests.delete(type.to_sym)
end

When('I send {int} request(s)') do |request_count|
  steps %Q{
    When I set environment variable "REQUEST_COUNT" to "#{request_count}"
    And I run the script "features/scripts/send_counted_requests.rb" using ruby synchronously
  }
end

When('I set up the maze-harness console') do
  steps %{
    Given I start a new shell
    And I input "cd features/fixtures/maze-harness" interactively
    And I input "bundle install" interactively
    And I wait for the shell to output a match for the regex "Bundle complete!" to stdout
  }
end
