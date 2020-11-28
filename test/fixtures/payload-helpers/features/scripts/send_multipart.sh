#!/usr/bin/env sh

curl -F foo=bar -F some_json='{"a": "b", "c": "d"}' -F file=@features/fixtures/file.txt -F json_file=@features/fixtures/file.json http://localhost:9339/notify
