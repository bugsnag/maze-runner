Maze.hooks.pre_complete do |scenario|
  if scenario.name == 'Mark as failed'
    Maze.scenario.mark_as_failed 'You told me to'
  end
end
