# frozen_string_literal: true

require 'json'

After do |scenario|
  if scenario.failed?
    if Server.stored_requests.empty?
      $logger.info 'No requests received'
    else
      $logger.info 'The following requests were received:'
      Server.stored_requests.each_with_index do |request, number|
        json = JSON.pretty_generate request
        $logger.info "Request #{number}: \n#{json}"
      end
    end
  end
end


