FROM elixir:alpine as build

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock /app/
COPY priv priv/


RUN mix deps.get
RUN mix local.rebar --force
RUN mix deps.compile

#COPY config/config.exs config/
#COPY config/prod.exs config/
#COPY config/releases.exs config/
COPY lib lib

RUN mix compile

RUN mix release

FROM elixir:alpine AS release

WORKDIR /app

ENV DOCKER_RELEASE=true

COPY --from=build /app/_build/prod/rel/edux ./

ENTRYPOINT [ "/app/bin/edux", "start" ]
