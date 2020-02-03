require 'logger'

if ENV['VERBOSE'] || ENV['DEBUG']
  $logger = Logger.new(STDOUT, level: Logger::DEBUG)
elsif ENV['QUIET']
  $logger = Logger.new(STDOUT, level: Logger::ERROR)
else
  $logger = Logger.new(STDOUT, level: Logger::INFO)
end