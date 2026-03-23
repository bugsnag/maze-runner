#!/bin/bash

curl -X POST -d @features/fixtures/payload.json -H "Content-Type: application/json" -U user:password -x http://localhost:9000 http://localhost:9339/notify
