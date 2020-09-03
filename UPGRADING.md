## v2 to v3

In v2, a single "request" endpoint received HTTP requests for both errors (notify) and sessions.  In v3 these have 
been separated, meaning:

### Client Configuration

Bugsnag clients must now be configured with different endpoints:
v2
```
config.setEndpoints("http://localhost:9339", "http://localhost:9339")
```
v3:
```
config.setEndpoints("http://localhost:9339/notify", "http://localhost:9339/sessions")
```

### Cucumber steps changed
 
Several Cucumber steps have changed their wording:

Old step | New step
----| -------- | 
I wait to receive a request | I wait to receive an error
I wait to receive {int} request(s) | I wait to receive {int} error(s)
I discard the oldest request | I discard the oldest error
I should receive no requests | I should receive no errors
the {string} header is not null | the error {string} header is not null
the {string} query parameter equals {string} | the error {string} query parameter equals {string}
the {string} query parameter is not null | the error {string} query parameter is not null
the {string} query parameter is a timestamp | the error {string} query parameter is a timestamp

### Cucumber steps removed

The following Cucumber steps are no longer required at the scenario level, as they are included
in the newly worded steps above.

TODO
