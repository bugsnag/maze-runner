# frozen_string_literal: true

require 'json'

Before do |scenario|
  STDOUT.puts "--- Scenario: #{scenario.name}"
end

After do |scenario|
  if scenario.failed?
    STDOUT.puts '^^^ +++'
    if Server.stored_requests.empty?
      $logger.info 'No requests received'
    else
      $logger.info 'The following requests were received:'
      Server.stored_requests.each.with_index(1) do |request, number|
        json = JSON.pretty_generate request
        $logger.info "Request #{number}: \n#{json}"
      end
    end
  end
end

