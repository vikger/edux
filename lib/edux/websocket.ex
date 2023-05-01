defmodule Edux.Websocket do
  require Logger

  @behaviour :cowboy_websocket

  @impl :cowboy_websocket
  def init(req, opts) do
    Logger.info("[websocket] init req => #{inspect(req)}")
    {:cowboy_websocket, req, opts, %{idle_timeout: :infinity}}
  end

  @impl :cowboy_websocket
  def websocket_init(_) do
    Logger.info("[websocket] init #{inspect(self())}")
    ### Temporary workaround to run elixir shell in elixir:alpine docker image
    env = %{
      "BINDIR" => "/usr/local/lib/erlang/erts-13.2/bin",
      "ELIXIR_VERSION" => "1.14.4",
      "EMU" => "beam",
      "HOME" => "/root",
      "HOSTNAME" => "8eb5104e621a",
      "LANG" => "C.UTF-8",
      "OTP_VERSION" => "25.3",
      "PATH" => "/usr/local/lib/erlang/erts-13.2/bin:/usr/local/lib/erlang/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      "PROGNAME" => "erl",
  "PWD" => "/",
      "REBAR3_VERSION" => "3.20.0",
      "ROOTDIR" => "/usr/local/lib/erlang",
      "SHLVL" => "3",
      "TERM" => "xterm"
    }
    System.get_env |> Map.keys |> Enum.each(&System.delete_env(&1))
    System.put_env(env)
    ### End of workaround
    {:ok, pid} = Edux.Shell.start_link(self())
    session_id = Edux.SessionManager.new(self())
    {:ok, %{pid: pid, session_id: session_id}}
  end

  @impl :cowboy_websocket
  def websocket_handle({:text, message}, state) do
    message
    |> Jason.decode!()
    |> process_message(state)
  end

  @impl :cowboy_websocket
  def websocket_info(message, state) do
    Logger.info("Websocket info #{inspect(message)}")
    {:reply, {:text, message}, state}
  end

  def process_message(%{"type" => "ping"}, state) do
    {:reply, {:text, Jason.encode!(%{"type" => "pong"})}, state}
  end

  def process_message(
        %{"type" => "compile", "source" => source},
        %{pid: pid, session_id: session_id} = state
      ) do
    Logger.info("compile #{source}")
    filename = "tmp_#{session_id}.ex"
    File.write(filename, source)
    Edux.Shell.command(pid, "c(\"#{filename}\")\n")
    {:reply, {:text, "c(\"<module>.ex\")\n"}, state}
  end

  def process_message(%{"type" => "run", "command" => command}, %{pid: pid} = state) do
    Logger.info("run")
    Edux.Shell.command(pid, command <> "\n")
    {:ok, state}
  end
end
