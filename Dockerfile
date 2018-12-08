FROM ruby:2.5-alpine as ci

RUN apk update && apk add docker

WORKDIR /app/
COPY Gemfile Gemfile.lock bugsnag-maze-runner.gemspec lib/version ./
RUN bundle install

COPY . ./

FROM ci as cli
ENTRYPOINT ["bundle", "exec", "maze-runner"]