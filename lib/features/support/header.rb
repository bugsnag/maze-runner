require 'digest/sha1'
require 'json'

def valid_bugsnag_integrity_header(request)
  header = request[:request]['Bugsnag-Integrity']

  if header.start_with?('sha1')
    assert_true(valid_sha_digest_header(request), 'Bugsnag-Integrity header does not match SHA1 digest.')
  elsif header.start_with?('simple')
    assert_true(valid_simple_digest_header(request), 'Bugsnag-Integrity header does not match simple digest.')
  else
    assert_true(false, 'Bugsnag-Integrity header does not match SHA1 or Request Length digest.')
  end
end

def valid_sha_digest_header(request)
  header = request[:request]['Bugsnag-Integrity']
  assert_not_nil(request[:body], 'No request body present')
  body = JSON.generate(request[:body])
  computed_digest = 'sha1 ' + Digest::SHA1.hexdigest(body.to_s)
  assert_equal(header, computed_digest, "SHA1 digest does not match request payload. Computed #{computed_digest}.")
  header == computed_digest
end

def valid_simple_digest_header(request)
  header = request[:request]['Bugsnag-Integrity']
  assert_not_nil(request[:body], 'No request body present')
  body = JSON.generate(request[:body])
  computed_digest = "simple #{body.to_s.bytesize}"
  assert_equal(header, computed_digest, "SHA1 digest does not match request payload. Computed #{computed_digest}.")
  header == computed_digest
end
