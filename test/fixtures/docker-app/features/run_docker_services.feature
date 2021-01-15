Feature: Running docker services and commands

    # Temporarily disabled due to networking issues - see [PLAT-5431]

    # Scenario: A service can be built and started
    #     When I start the service "sends_request"
    #     And I wait to receive an error
    #     Then the error payload field "somedata" equals "data"
    #     And the exit code of the last docker command was 0
    #     And the last run docker command exited successfully
    #     And the last run docker command output "SOME OUTPUT"

    # Scenario: A service can be started with a command
    #     When I run the service "sends_request" with the command "curl -F somedata=manual http://docker-tests:9339"
    #     And I wait to receive an error
    #     Then the error payload field "somedata" equals "manual"
    #     And the last run docker command exited successfully

    # Scenario: A service can be started with a multiline command
    #     When I run the service "sends_request" with the command
    #     """
    #     curl -F somedata=multiline http://docker-tests:9339
    #     curl -F somedata=multiline2 http://docker-tests:9339
    #     """
    #     And I wait to receive 2 errors
    #     Then the error payload field "somedata" equals "multiline"
    #     And I discard the oldest error
    #     And the error payload field "somedata" equals "multiline2"
    #     And the last run docker command exited successfully

    Scenario: A services error status can be checked
        When I run the service "sends_request" with the command "/foo"
        Then the last run docker command did not exit successfully

    Scenario: A service can be run interactively when it does not require interaction
        When I run the service "interactive" interactively
        And I wait for the shell prompt "# "
        And I input "./hello" interactively
        Then I wait for the shell to output "Hello" to stdout
        And the last interactive command exited successfully

    Scenario: A service can be run interactively that does require interaction
        When I run the service "interactive" interactively
        And I wait for the shell prompt "# "
        And I input "./your-name" interactively
        Then I wait for the shell to output "What is your name?" to stdout
        When I input "Santa Claus" interactively
        Then I wait for the shell to output "Hello, Santa Claus!" to stdout
        And the last interactive command exited successfully

    Scenario: A service can be run interactively with lots of interaction
        When I run the service "interactive" interactively
        And I wait for the shell prompt "# "
        And I input "./guessing-game" interactively
        Then I wait for the shell to output "What number am I thinking of?" to stdout
        When I input "1" interactively
        Then I wait for the shell to output "Nope, it's not 1. Try again!" to stdout
        When I input "12" interactively
        Then I wait for the shell to output "Nope, it's not 12. Try again!" to stdout
        When I input "456" interactively
        Then I wait for the shell to output "Nope, it's not 456. Try again!" to stdout
        When I input "ugh" interactively
        Then I wait for the shell to output "Nope, it's not ugh. Try again!" to stdout
        When I input "123" interactively
        Then I wait for the shell to output "Yeah, it's 123!" to stdout
        And the last interactive command exited successfully

    Scenario: A service can be run with a command interactively when it does not require interaction
        When I run the service "interactive" with the command "./hello" interactively
        Then I wait for the shell to output "Hello" to stdout
        And the last run docker command exited successfully

    Scenario: A service can be run with a command interactively that does require interaction
        When I run the service "interactive" with the command "./your-name" interactively
        Then I wait for the shell to output "What is your name?" to stdout
        When I input "Santa Claus" interactively
        Then I wait for the shell to output "Hello, Santa Claus!" to stdout
        And the last run docker command exited successfully

    Scenario: A service can run multiple scripts interactively
        When I run the service "interactive" interactively
        And I wait for the shell prompt "# "
        And I input "echo 'beep boop'" interactively
        Then I wait for the shell to output "beep boop" to stdout

        When I input "./your-name" interactively
        Then I wait for the shell to output "What is your name?" to stdout
        When I input "Santa Claus" interactively
        Then I wait for the shell to output "Hello, Santa Claus!" to stdout

        When I input "./hello" interactively
        Then I wait for the shell to output "Hello" to stdout

        And the last interactive command exited successfully

    Scenario: A service can be run multiple scripts with different exit codes
        When I run the service "interactive" interactively
        And I wait for the shell prompt "# "
        And I input "(exit 0)" interactively
        Then the last interactive command exited successfully
        When I input "(exit 1)" interactively
        Then the last interactive command exited with an error code
        When I input "(exit 127)" interactively
        Then the last interactive command exit code is 127
        When I input "(exit 0)" interactively
        Then the last interactive command exited successfully
