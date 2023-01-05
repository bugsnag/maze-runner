#!/usr/bin/env sh

curl -H 'Content-Encoding: gzip' -H 'Bugsnag-Integrity: sha1 af07a2fb3422d988c55e0af35b3f8a6ee8095d7b' --data-binary @features/fixtures/file.json.gz http://localhost:9339/traces
