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
