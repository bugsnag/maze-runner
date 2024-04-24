Feature: Using the AWS SAM CLI to directly invoke Lambda functions

Scenario: Executing a lambda function with 'sam invoke'
  Given I invoke the "HelloWorldFunction" lambda in "features/fixtures/ruby-app"
  Then the lambda response "body.message" equals "Hello World!"
  And the lambda response "body.message" starts with "Hello"
  And the lambda response "body.message" ends with "World!"
  And the lambda response "body.message" matches the regex "W[d-r]{4}!$"
  And the lambda response "body.message" is not null
  And the lambda response "body.does.not.exist" is null
  And the lambda response "body.is_lambda" is true
  And the lambda response "body.is_not_lambda" is false
  And the lambda response "body.empty_array" is an array with 0 elements
  And the lambda response "body.numbers" is a non-empty array
  And the lambda response "body.numbers" is an array with 5 elements
  And the lambda response "body.numbers.0" equals 1
  And the lambda response "body.numbers.4" equals 5
  And the lambda response "statusCode" equals 200
  And the lambda response "statusCode" is greater than 199
  And the lambda response "statusCode" is less than 201
  And the SAM exit code equals 0

Scenario: Executing a lambda function with 'sam invoke' and an event
  Given I invoke the "HelloWorldFunction" lambda in "features/fixtures/ruby-app" with the "events/example-event.json" event
  Then the lambda response "body.message" equals "Hello World!"
  And the lambda response "statusCode" equals 200
  And the SAM exit code equals 0

Scenario: Executing a lambda function with 'sam invoke' that raises
  Given I invoke the "HelloWorldFunction" lambda in "features/fixtures/ruby-app" with the "events/error event.json" event
  Then the lambda response "errorMessage" equals "oh no"
  And the lambda response "errorType" is not null
  And the lambda response "stackTrace" is a non-empty array
  And the lambda response "body" is null
  And the lambda response "statusCode" is null
  And the SAM exit code equals 0

Scenario: Executing a node lambda function with 'sam invoke' and an event
  Given I invoke the "HelloWorldFunction" lambda in "features/fixtures/node-app" with the "events/event.json" event
  Then the lambda response "body.message" equals "ah hah"
  And the lambda response "body.event.body" equals '{"message": "hello world"}'
  And the lambda response "body.event.queryStringParameters.foo" equals "bar"
  And the lambda response "body.event.httpMethod" equals "POST"
  And the lambda response "body.event.headers.User-Agent" equals "Custom User Agent String"
  And the lambda response "body.event.requestContext.identity.sourceIp" equals "127.0.0.1"
  And the lambda response "body.context.callbackWaitsForEmptyEventLoop" is true
  And the lambda response "statusCode" equals 201
  And the SAM exit code equals 0

Scenario: Executing two lambda functions with 'sam invoke'
  Given I invoke the "HelloWorldFunction" lambda in "features/fixtures/ruby-app"
  Then the lambda response "body.message" equals "Hello World!"
  And the lambda response "body.numbers" is an array with 5 elements
  And the lambda response "statusCode" is greater than 199
  And the lambda response "statusCode" is less than 201
  And the SAM exit code equals 0
  Given I invoke the "HelloWorldFunction" lambda in "features/fixtures/node-app" with the "events/event.json" event
  Then the lambda response "body.message" equals "ah hah"
  And the lambda response "body.event.body" equals '{"message": "hello world"}'
  And the lambda response "body.event.queryStringParameters.foo" equals "bar"
  And the lambda response "body.event.httpMethod" equals "POST"
  And the lambda response "body.event.headers.User-Agent" equals "Custom User Agent String"
  And the lambda response "body.event.requestContext.identity.sourceIp" equals "127.0.0.1"
  And the lambda response "body.context.callbackWaitsForEmptyEventLoop" is true
  And the lambda response "statusCode" equals 201
  And the SAM exit code equals 0

Scenario: Executing a lambda function that returns a HTML body
  Given I invoke the "HelloWorldFunction" lambda in "features/fixtures/python-app"
  Then the lambda response "body" contains "<title>my cool page</title>"
  And the lambda response "body" contains "<h1>my cool page</h1>"
  And the lambda response "body" contains "<p>stuff and things</p>"
  And the lambda response "statusCode" equals 200
  And the SAM exit code equals 0

Scenario: Executing a lambda function that does not respond
  Given I invoke the "ProcessExitFunction" lambda in "features/fixtures/node-app"
  Then the lambda response "errorMessage" contains "Error: Runtime exited with error: exit status 1"
  And the lambda response "errorType" equals "Runtime.ExitError"
  And the lambda response "body" is null
  And the SAM exit code equals 1
