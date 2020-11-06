Feature: Testing multipart requests work correctly

    Scenario: The request body matches an expected error payload
        When I run the script "features/scripts/send_multipart.sh" synchronously
        Then I wait to receive a request

        # Verify the general multipart validation works
        And the request contains multipart form-data and corresponding headers
        And the multipart request has 4 fields

        # Verifying new and old nullability checks work
        And the multipart field "foo" is not null
        And the field "foo" for multipart request is not null
        And the multipart field "null" is null
        And the field "null" for multipart request is null

        # Verifying new and old string testing works, including stringified files
        And the multipart field "foo" equals "bar"
        And the field "foo" for multipart request equals "bar"
        And the multipart field "file" equals "hello world"

        # Verifying body and field comparisons with JSON fixtures work
        And the multipart field "json_file" matches the JSON fixture in "features/fixtures/file.json"
        And the multipart body matches the JSON fixture in "features/fixtures/full_multipart.json"
        And the multipart body does not match the JSON fixture in "features/fixtures/breadcrumb_match.json"
