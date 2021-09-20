# @!group Document steps

# Starts the document server manually.  It will be stopped automatically at the end of each scenario
# (if started in this way).
When('I start the document server') do
  Maze::DocumentServer.manual_start
end
