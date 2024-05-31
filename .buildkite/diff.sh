#!/usr/bin/sh

if [ -z "$BUILDKITE_PULL_REQUEST_BASE_BRANCH" ]; then
    git diff --name-only HEAD~1
else
    git diff --name-only $(git rev-parse --short --verify $BUILDKITE_PULL_REQUEST_BASE_BRANCH)
fi