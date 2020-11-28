#!/usr/bin/env ruby

require 'net/http'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
request = Net::HTTP::Post.new('/notify')
request['Content-Type'] = 'application/json'

request.body = case ENV['request_type']
when 'equal'
 '{"animals":["bear","fox","goat","parrot"],"fruits":{"apple":{"color":"red","types":248},"cherry":{"color":"black","types":17}}}'
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
else
  exit(1)
end

http.request(request)
