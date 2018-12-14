FROM docker/compose:1.23.2 as compose
FROM ruby:2.5-alpine as ci

ENV GLIBC 2.28-r0

RUN apk update && apk add --no-cache openssl ca-certificates curl libgcc && \
    curl -fsSL -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -fsSL -o glibc-$GLIBC.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC/glibc-$GLIBC.apk && \
    apk add --no-cache glibc-$GLIBC.apk && \
    ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ && \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib && \
    ln -s /usr/lib/libgcc_s.so.1 /usr/glibc-compat/lib && \
    rm /etc/apk/keys/sgerrand.rsa.pub glibc-$GLIBC.apk && \
    apk del curl

COPY --from=compose /usr/local/bin/docker /usr/local/bin/docker-compose /usr/local/bin/

WORKDIR /app/

# We dont copy the gemfile in because this builds a gem so it needs the source
COPY . ./
RUN bundle install

FROM ci as cli
ENTRYPOINT ["bundle", "exec", "maze-runner"]