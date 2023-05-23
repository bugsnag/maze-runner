FROM ruby:3-alpine
WORKDIR /app
COPY run.rb .

ENTRYPOINT ["ruby", "run.rb"]
