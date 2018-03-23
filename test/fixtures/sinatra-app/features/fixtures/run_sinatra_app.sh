#!/usr/bin/env ruby

require "sinatra"
require "bugsnag"

class InvariantException < Exception; end

Bugsnag.configure do |config|
  config.endpoint = "http://localhost:#{ENV['MOCK_API_PORT']}"
  config.app_version = "2.5.1"
end

set :port, ENV['DEMO_APP_PORT']
set :logging, false
set :dump_errors, false
set :raise_errors, true
set :show_exceptions, false

use Bugsnag::Rack

get '/syntax-error' do
  make_a_syntax_error
end

get '/notify' do
  send_manual_notify
end

get '/metadata' do
  send_metadata_notification
end

def send_manual_notify
  if context = params[:context]
    Bugsnag.before_notify_callbacks << lambda do |report|
      report.context = context
    end
  end
  Bugsnag.notify(InvariantException.new("The cake was rotten"))
end

def make_a_syntax_error
  rt()
end

def send_metadata_notification
  Bugsnag.notify(InvariantException.new("The cake was really badly rotten")) do |report|
    report.add_tab(:cake, {
      :went_bad => Time.now.strftime("%s"),
      :cake_type => "Carrot"
    })
  end
end
