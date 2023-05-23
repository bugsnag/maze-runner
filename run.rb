at_exit do
  puts 'goodbye'
end

puts 'Hello'
(1..1000).each_with_index do |count|
  puts count
  sleep 1
end
