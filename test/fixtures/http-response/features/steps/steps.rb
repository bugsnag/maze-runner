When('I ignore invalid {word}') do |type|
  Maze.config.captured_invalid_requests -= [type.to_sym]
end
