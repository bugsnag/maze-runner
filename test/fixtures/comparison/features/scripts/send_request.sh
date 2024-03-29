#!/usr/bin/env ruby

require 'net/http'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
endpoint = if ENV['request_type'].end_with? '-log'
             '/logs'
           else
             '/notify'
           end
STDOUT.puts "sending to endpoint #{endpoint}"
request = Net::HTTP::Post.new(endpoint)
request['Content-Type'] = 'application/json'

request.body = case ENV['request_type']
when 'equal'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"red","types":248},"cherry":{"color":"black","types":17}}}'
when 'caseless equal'
 '{"animals":["bEAr","fOx","gOAt","pARROt"]}'
when 'fuzzy match'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"green","types":248},"cherry":{"color":"white","types":17}}}'
when 'subset'
 '{"items":[{"subset":{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"red","types":248},"cherry":{"color":"black","types":17}}}}]}'
when 'missing key'
 '{"fruits":{"apple":{"color":"red","types":248},"cherry":{"color":"black","types":17}}}'
when 'extra object in array'
 '{"animals":["bear","fox","goat","parrot","sheep"],"fruits":{"apple":{"color":"red","types":248},"cherry":{"color":"black","types":17}}}'
when 'different object in array'
 '{"animals":["bear","fox","sheep","parrot"],"fruits":{"apple":{"color":"red","types":248},"cherry":{"color":"black","types":17}}}'
when 'missing nested object key'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"red"},"cherry":{"color":"black","types":17}}}'
when 'different object for nested key'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":[],"types":248},"cherry":{"color":"black","types":17}}}'
when 'fuzzy mismatch'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"red-orange","types":248},"cherry":{"color":"black","types":17}}}'
when 'numerics'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"red","types":687},"cherry":{"color":"black","types":18.39045}}}'
when 'ignore'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":"some nonsense","cherry":{"color":"black","types":17}}}'
when 'different fixnum in object'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"red","types":24},"cherry":{"color":"black","types":17}}}'
when 'ordered 1'
 '{"foo":"a", "bar":"b"}'
when 'ordered 2'
 '{"foo":"b", "bar":"a"}'
when 'values'
 '{"values":{"uuid":"123e4567-e89b-12d3-a456-426614174000","number":1.23,"integer":123,"date":"2001-02-03"}}'
when 'info-log'
 '{"level":"INFO","message":"Today is 2021-02-03"}'
when 'error-log'
 '{"level":"ERROR","message":"The world is no longer on pause"}'
when 'error 1'
 '{"events":[{"null?":"nope","count":"one"}]}'
when 'error 2'
 '{"events":[{"count":"two"}]}'
else
  exit(1)
end

http.request(request)
