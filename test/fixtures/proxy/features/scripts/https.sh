#!/bin/bash

curl -X POST -d @features/fixtures/payload.json -H "Content-Type: application/json" -x https://localhost:9000 --proxy-insecure http://localhost:9339/notify
