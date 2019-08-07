ARG BUILDKITE_BRANCH
FROM 855461928731.dkr.ecr.us-west-1.amazonaws.com/maze-runner:${BUILDKITE_BRANCH}-ci

RUN apk add bash curl

COPY . /app
WORKDIR /app
