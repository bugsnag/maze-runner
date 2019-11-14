FROM docker/compose:1.24.0 as compose
FROM ruby:2.5-alpine as ci

ENV GLIBC_VERSION 2.28-r0

RUN apk add --no-cache openssl ca-certificates curl-dev libgcc build-base ruby-dev build-base libffi-dev curl

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk" \
  && apk --no-cache add "glibc-$GLIBC_VERSION.apk" \
  && rm "glibc-$GLIBC_VERSION.apk" \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk" \
  && apk --no-cache add "glibc-bin-$GLIBC_VERSION.apk" \
  && rm "glibc-bin-$GLIBC_VERSION.apk" \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-i18n-$GLIBC_VERSION.apk" \
  && apk --no-cache add "glibc-i18n-$GLIBC_VERSION.apk" \
  && rm "glibc-i18n-$GLIBC_VERSION.apk" \
  && ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ \
  && ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib \
  && ln -s /usr/lib/libgcc_s.so.1 /usr/glibc-compat/lib \
  && rm /etc/apk/keys/sgerrand.rsa.pub

RUN wget -q https://www.browserstack.com/browserstack-local/BrowserStackLocal-linux-x64.zip \
  && unzip BrowserStackLocal-linux-x64.zip \
  && rm BrowserStackLocal-linux-x64.zip

COPY --from=compose /usr/local/bin/docker /usr/local/bin/docker-compose /usr/local/bin/

WORKDIR /app/

# We dont copy the gemfile in because this builds a gem so it needs the source
COPY . ./
RUN bundle install

FROM ci as cli
ENTRYPOINT ["bundle", "exec", "maze-runner"]