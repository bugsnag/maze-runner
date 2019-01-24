require 'securerandom'

# The apikey that should be used on this test run
$api_key = SecureRandom.hex(16).tr('+/=', 'xyz')
TIMESTAMP_REGEX = /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/