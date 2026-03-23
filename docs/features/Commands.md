# Commands

Commands provide a mechanism for feeding instructions and other information from Maze Runner to test fixtures.  Commands can be added to a list in the form of arbitrary Ruby hashes.  HTTP endpoints are exposed for test fixtures to make GET requests, with the endpoints responding with commands in JSON format.

## Producing commands

Any Ruby hash can be added to the list of Commands, for example:
```
  command = {
    action: action,
    scenario_name: scenario_name,
    scenario_mode: $scenario_mode,
    sessions_endpoint: $sessions_endpoint,
    notify_endpoint: $notify_endpoint
  }
  Maze::Server.commands.add command
```

How commands are formed is governed by the contract formed between the Cucumber scenarios and test fixture.

Each time a command is added, two additional fields are automatically set:
- `:uuid` - a UUID for the command.
- `:run_uuid` - the UUID for the whole execution of Maze Runner (as assigned to `Maze.run_uuid` when the run starts).

## Consuming commands

The endpoints provided are as follows:

- `/command` - Responds with the next command in the queue.  Each time a request is made, the next command is the queue is returned.  If there is nothing left in the queue then a no-op command will be returned.
- `/command?after=uuid` - Responds with the next command in the queue after that with the UUID given, or no-op if there are no commands following it.  If there is no command with the UUID then a 400 response will be made.
- `/idem-command?after=uuid` - As previous, except that if there is no command with the UUID then a command will be served to clear the client's last known UUID.
- `/commands` - Returns all commands held in the queue, as a JSON array.

## No-op commands

Test fixtures can be implemented to poll one of the above endpoints, with commands being added to the queue throughout the scenario.  No-op commands can be returned as detailed above and look like this:
```
{
  "action": "noop", 
  "message": "No commands queued"
}
```
