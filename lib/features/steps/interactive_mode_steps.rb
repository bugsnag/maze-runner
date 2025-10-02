# poll for user input
# and print it out
When('I do what you tell me') do
  $stdout.puts "Entering interactive mode. Type 'exit' to leave."
  loop do
    $stdout.puts "> "
    input = $stdin.gets.chomp
    break if input == 'exit'

    step input
  end
  $stdout.puts "Exiting interactive mode."
end

# I display any errors received for 5 seconds
Then('I display any {request_type} received for {int} seconds') do |request_type, time|
  list = Maze::Server.list_for(request_type)
  display_requests(list, request_type, time)
end

def display_requests(list, list_name, timeout)
  wait = Maze::Wait.new(interval: 0.5, timeout: timeout)
  wait.until do
    # Just display all received requests
    if list.size_remaining > 0
      $stdout.puts "********\nReceived\n********\n\n #{list.current[:body]}"
      list.next
    end
    false
  end
end
