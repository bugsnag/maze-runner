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
```diff
- I wait to receive a request
+ asdasd
```

### Cucumber steps removed

The following Cucumber steps are no longer required at the scenario level, as they are included
in the newly worded steps above.

TODO
