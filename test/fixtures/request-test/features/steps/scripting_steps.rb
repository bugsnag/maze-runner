When(/^I send an HTTP 1.1 request$/) do
  `curl --header "Content-Type: application/json" \
    --http1.1 \
    --request POST \
    --data '{"foo":"FOO","bar":"BAR"}' \
    http://localhost:#{MOCK_API_PORT}`
end

When(/^I send an HTTP 1.0 request$/) do
  `curl --header "Content-Type: application/json" \
    --http1.0 \
    --request POST \
    --data '{"foo":"FOO","bar":"BAR"}' \
    http://localhost:#{MOCK_API_PORT}`
end

