defmodule Edux.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HeckMeck.Router,
        options: [port: 5555, dispatch: dispatch()]
      )
    ]

    opts = [strategy: :one_for_one, name: Edux.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", Edux.Websocket, []},
         {:_, Plug.Cowboy.Handler, {Edux.Router, []}}
       ]}
    ]
  end
end
