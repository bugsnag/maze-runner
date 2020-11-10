require 'digest/sha1'
require 'json'

def valid_bugsnag_integrity_header(request)
  header = request[:request]['Bugsnag-Integrity']
  digests = request[:digests]
  if header.start_with?('sha1')
    computed_digest = "sha1 #{digests[:sha1]}"
  elsif header.start_with?('simple')
    computed_digest = "simple #{digests[:simple]}"
  else
    return false
  end
  header == computed_digest
end
