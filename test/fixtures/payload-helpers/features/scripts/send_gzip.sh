#!/usr/bin/env sh

curl -H 'Content-Encoding: gzip' --data-binary @features/fixtures/file.json.gz http://localhost:9339/traces
