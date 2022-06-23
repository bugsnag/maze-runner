When('I issue a command to notify a {string} handled error') do |metadata|
  command = {
    action: 'notify_handled',
    metadata: metadata
  }
  Maze::Server.commands.add command
end

When('I run the next command') do
  step 'I click the element "run_command"'
end

Then('Maze Runner reports the current platform as {string}') do |platform|
  Maze.check.equal(platform, Maze::Helper.get_current_platform)
end
