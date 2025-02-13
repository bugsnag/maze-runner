curl http://localhost:9340/payload.json -o payload.json
curl -X POST -d @payload.json -H "Content-Type: application/json" http://localhost:9339/notify
