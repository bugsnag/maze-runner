FROM ruby:2.7-alpine as ci

RUN apk update && apk add docker

WORKDIR /app/
COPY . ./
RUN bundle install

FROM ci as cli
ENTRYPOINT ["bundle", "exec", "maze-runner"]
