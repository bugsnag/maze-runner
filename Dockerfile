FROM ruby:2.5-alpine as ci

WORKDIR /app/
COPY . ./
RUN bundle install

FROM test as cli
ENTRYPOINT ["bundle", "exec", "maze-runner"]