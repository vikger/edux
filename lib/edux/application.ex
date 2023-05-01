defmodule Edux.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    if System.get_env("DOCKER_RELEASE") == "true" do
      reset_env()
    else
      :ok
    end

    children = [
      Edux.SessionManager,
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Edux.Router,
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

  defp reset_env() do
    env = %{
      "BINDIR" => "/usr/local/lib/erlang/erts-13.2/bin",
      "ELIXIR_VERSION" => "1.14.4",
      "EMU" => "beam",
      "HOME" => "/root",
      "HOSTNAME" => "8eb5104e621a",
      "LANG" => "C.UTF-8",
      "OTP_VERSION" => "25.3",
      "PATH" =>
        "/usr/local/lib/erlang/erts-13.2/bin:/usr/local/lib/erlang/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      "PROGNAME" => "erl",
      "PWD" => "/",
      "REBAR3_VERSION" => "3.20.0",
      "ROOTDIR" => "/usr/local/lib/erlang",
      "SHLVL" => "3",
      "TERM" => "xterm"
    }

    System.get_env() |> Map.keys() |> Enum.each(&System.delete_env(&1))
    System.put_env(env)
  end
end
