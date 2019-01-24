require 'logger'

if ENV['VERBOSE'] || ENV['DEBUG']
  $logger = Logger.new(STDOUT, level: Logger::DEBUG)
else
  $logger = Logger.new(STDOUT, level: Logger::WARN)
end