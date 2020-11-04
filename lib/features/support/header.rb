require 'digest/sha1'
require 'json'

def valid_bugsnag_integrity_header(request)
  valid = valid_sha_digest_header(request) || valid_simple_digest_header(request)
  assert_true(valid, "Bugsnag-Integrity header does not match SHA1 or Request Length digest.")
end

def valid_sha_digest_header(request)
  header = request[:request]["Bugsnag-Integrity"]
  assert_not_nil(request[:body], "No request body present")
  body = JSON.generate(request[:body])
  computed_digest = "sha1 " + Digest::SHA1.hexdigest(body.to_s)
  assert_equal(header, computed_digest, "SHA1 digest does not match request payload. Computed #{computed_digest} from #{body}.")
  return header == computed_digest
end

def valid_simple_digest_header(request)
  header = request[:request]["Bugsnag-Integrity"]
  assert_not_nil(request[:body], "No request body present")
  body = JSON.generate(request[:body])
  computed_digest = "simple #{body.to_s.size}"
  assert_equal(header, computed_digest, "SHA1 digest does not match request payload. Computed #{computed_digest} from #{body}.")
  return header == computed_digest
end
