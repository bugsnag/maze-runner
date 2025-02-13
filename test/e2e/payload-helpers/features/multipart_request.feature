Feature: Testing multipart requests work correctly

    Scenario: The request body matches an expected error payload
        When I run the script "features/scripts/send_multipart.sh" synchronously
        Then I wait to receive an upload

        # Verify the general multipart validation works
        And the upload request is valid multipart form-data
        And the upload multipart request has 4 fields

        # Verifying new and old nullability checks work
        And the upload payload field "foo" is not null
        And the field "foo" for multipart upload is not null
        And the upload payload field "null" is null
        And the field "null" for multipart upload is null

        # Verifying new and old string testing works, including stringified files
        And the upload payload field "foo" equals "bar"
        And the field "foo" for multipart upload equals "bar"
        And the upload payload field "file" equals "hello world"

        # Verifying body and field comparisons with JSON fixtures work
        And the upload multipart field "json_file" matches the JSON file in "features/fixtures/file.json"
        And the upload multipart body matches the JSON file in "features/fixtures/full_multipart.json"
        And the upload multipart body does not match the JSON file in "features/fixtures/breadcrumb_match.json"

    Scenario: Multiple multipart payloads can be validated at once
        When I run the script "features/scripts/send_multi_multipart.sh" synchronously
        Then I wait to receive 3 uploads
        And all upload requests are valid multipart form-data
