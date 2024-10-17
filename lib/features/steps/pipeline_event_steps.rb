# @!group Pipeline_event steps

# Checks to see if an event is available in the pipeline
Then('the last event is available via the data access api') do
  event_id = Maze::Server.events.last[:event_id]

  raise Test::Unit::AssertionFailedError.new('Event id could not be found from last event') if event_id.nil?

  # Check if the event exists in the pipeline_events list already
  return if Maze::Server.pipeline_events.any? { |event| event[:event_id].eql?(event_id) }

  # if not, attempt to get the event via the data access api
  event = get_event_from_api(event_id)

  unless event
    raise Test::Unit::AssertionFailedError.new <<-MESSAGE
    Could not find event with id #{event_id} via the data access api
    MESSAGE
  end
end

Then('the last event is not available via the data access api') do
  event_id = Maze::Server.events.last[:event_id]

  raise Test::Unit::AssertionFailedError.new('Event id could not be found from last event') if event_id.nil?

  if Maze::Server.pipeline_events.any? { |event| event[:event_id].eql?(event_id) }
    raise Test::Unit::AssertionFailedError.new <<-MESSAGE
    Event with id #{event_id} already exists in the events pulled via data access api
    MESSAGE
  end

  # if not, attempt to get the event via the data access api
  event = get_event_from_api(event_id)

  if event
    raise Test::Unit::AssertionFailedError.new <<-MESSAGE
    Found event with id #{event_id} via the data access api
    MESSAGE
  end
end

def get_event_from_api(event_id)
  wait = Maze::Wait.new(interval: 3, timeout: 15)
  received_event = wait.until do
    event = data_access_api.get_event(event_id)
    # Probably needs some error handling somewhere
    if event.has_key?('errors')
      false
    else
      event
    end
  end
  if received_event
    Maze::Server.pipeline_events.add({
      body: JSON.parse(received_event),
      request: received_event,
      event_id: event_id
    })
  end

  received_event
end

def data_access_api
  @data_access_api ||= Maze::Client::Bugsnag::DataAccessApi.new
end
