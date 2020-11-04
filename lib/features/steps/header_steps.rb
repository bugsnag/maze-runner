# @!group Header steps

# Checks that the Bugsnag-Integrity header is a SHA1 or simple digest
#
When("the Bugsnag-Integrity header is valid") do
  valid_bugsnag_integrity_header(Server.current_request)
end
