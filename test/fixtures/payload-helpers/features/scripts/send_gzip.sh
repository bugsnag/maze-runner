#!/usr/bin/env sh

curl -H 'Content-Encoding: gzip' -H 'Bugsnag-Integrity: sha1 34d70c23342679a679c147755762d1e825c79e70' --data-binary @features/fixtures/file.json.gz http://localhost:9339/traces
