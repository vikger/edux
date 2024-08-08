# Edux

Edux is a multiuser Elixir shell that runs in the browser. You can create and compile an Elixir
module on the left side of the screen, and/or execute single commands in the Elixir shell by
entering the command and pressing `Run`.

## Prerequisites

* `docker`, `docker compose`
* Debian/Ubuntu: `docker-ce`, `docker-ce-cli`, `docker-compose-plugin` packages
* the old v1 `docker-compose` Python package might fail

## Installation

After cloning the repository, you can run the application with `iex -S mix`. Alternatively,
you can build a docker image and run it in daemon mode.

```
docker build -t edux .
docker run --name edux -d edux
```

If you want the service to run on a different port than the default (5555):

```
docker run --name edux -d -p <port>:5555 edux
```

You can also build and run the application with `docker compose`:

```
docker compose build
docker compose up -d
```
