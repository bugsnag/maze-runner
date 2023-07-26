#!/usr/bin/env sh

curl -H 'Content-Encoding: gzip' -H 'Bugsnag-Integrity: sha1 bd1cbbd2ab9b05a96cbb83a6bcac829ff255a9fe' -H 'Bugsnag-Sent-At: 2023-06-30T08:31:46.016Z' -H 'Bugsnag-Span-Sampling: 1:4' -H 'Bugsnag-Api-Key: 12312312312312312312312312312312' --data-binary @features/fixtures/file.json.gz http://localhost:9339/traces
