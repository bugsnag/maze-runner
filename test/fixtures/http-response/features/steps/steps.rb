When('I ignore invalid {word}') do |type|
  Maze.config.captured_invalid_requests.delete(type.to_sym)
end
