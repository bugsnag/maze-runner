#!/usr/bin/env sh

curl -H 'Content-Encoding: gzip' -H 'Bugsnag-Integrity: sha1 bd1cbbd2ab9b05a96cbb83a6bcac829ff255a9fe' --data-binary @features/fixtures/file.json.gz http://localhost:9339/traces
