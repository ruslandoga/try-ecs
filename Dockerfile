FROM hexpm/elixir:1.12.3-erlang-24.1.4-alpine-3.14.2 as build

# install build dependencies
RUN apk add --no-cache --update git build-base

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs config/
RUN mix deps.get
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile
COPY config/runtime.exs config/

# build assets
COPY assets assets
RUN mix esbuild --no-runtime-config default --minify
RUN mix phx.digest

# build release
COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.14.2 AS app
RUN apk add --no-cache --update bash openssl libgcc libstdc++

WORKDIR /app

RUN chown nobody:nobody /app
USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/e ./

ENV HOME=/app

CMD /app/bin/e start
