When('I add a command with message {string}') do |message|
  command = {
    message: message
  }
  Maze::Server.commands.add command
end

When('I generate a series of commands with sequential UUIDs') do
  Maze::Server.commands.add({ message: 'first'})
  Maze::Server.commands.get(0)[:uuid] = '1'
  Maze::Server.commands.add({ message: 'second'})
  Maze::Server.commands.get(1)[:uuid] = '2'
  Maze::Server.commands.add({ message: 'third'})
  Maze::Server.commands.get(2)[:uuid] = '3'
  Maze::Server.commands.add({ message: 'fourth'})
  Maze::Server.commands.get(3)[:uuid] = '4'
end

When('I run the {string} test script') do |test_script|
  steps %Q{
    And I run the script "features/scripts/#{test_script}.rb" using ruby synchronously
  }
end

When('I run the {string} test script with UUID {string}') do |test_script, uuid|
  steps %Q{
    When I set environment variable "COMMAND_UUID" to "#{uuid}"
    And I run the script "features/scripts/#{test_script}.rb" using ruby synchronously
  }
end
