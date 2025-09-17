# frozen_string_literal: true

# @!group Error config steps

#
# Shortcut to waiting to receive requests for error configs
#
# @step_input count [Integer] Number of error config requests expected
Then('I wait for {int} error config(s) to be requested') do |count|
  step "I wait to receive #{count} error config requests"
end

Then('I prepare an error config with:') do |table|
  Maze.check.equal(%w[type name value], table.column_names, 'Error config table expects column headers "type", "name" and "value"')
  ErrorConfigSupport.prepare_error_config(table.hashes)
end