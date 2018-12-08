FROM ruby:2.5-alpine as test

WORKDIR /app/
COPY . ./
RUN bundle install

FROM test as cli
ENTRYPOINT ["bundle", "exec", "maze-runner"]