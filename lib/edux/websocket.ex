defmodule Edux.Websocket do
  require Logger

  @behaviour :cowboy_websocket


  @impl :cowboy_websocket
  def init(req, opts) do
    Logger.info("[websocket] init req => #{inspect(req)}")
    {:cowboy_websocket, req, opts}
  end

  @impl :cowboy_websocket
  def websocket_init(_) do
    Logger.info("[websocket] init")
    {:ok, pid} = Edux.Shell.start_link(self())
    state = %{pid: pid}
    {:ok, state}
  end

  @impl :cowboy_websocket
  def websocket_handle({:text, message}, state) do
    message
    |> Jason.decode!()
    |> process_message(state)
  end

  @impl :cowboy_websocket
  def websocket_info(message, state) do
    Logger.info("Websocket info #{inspect message}")
    {:reply, {:text, message}, state}
  end

  def process_message(%{"type" => "ping"}, state) do
    {:reply, {:text, Jason.encode!(%{"type" => "pong"})}, state}
  end

  def process_message(%{"type" => "compile", "source" => source}, state) do
    Logger.info("compile #{source}")
    {:reply, {:text, "OK"}, state}
  end

  def process_message(%{"type" => "run", "command" => command}, %{pid: pid} = state) do
    Logger.info("run")
    Edux.Shell.command(pid, command <> "\n")
    {:ok, state}
  end
end
