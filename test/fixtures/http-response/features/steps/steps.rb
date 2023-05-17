When('I ignore invalid {request_type}') do |type|
  Maze.config.captured_invalid_requests.delete(type.to_sym)
end
