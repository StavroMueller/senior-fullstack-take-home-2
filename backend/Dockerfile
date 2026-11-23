FROM hexpm/elixir:1.18.4-erlang-27.3.4.9-alpine-3.20.9

RUN apk add --no-cache build-base git inotify-tools
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=dev

COPY mix.exs mix.lock .formatter.exs .credo.exs ./
COPY apps apps
COPY config config
COPY credo_checks credo_checks
RUN mix deps.get && mix deps.compile && mix compile

EXPOSE 4000
