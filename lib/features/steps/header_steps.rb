# @!group Header steps

# Checks that the Bugsnag-Integrity header is a SHA1 or simple digest
#
When('the Bugsnag-Integrity header is valid') do
  assert_true(valid_bugsnag_integrity_header(Server.errors.current), 'Invalid Bugsnag-Integrity header detected')
end
