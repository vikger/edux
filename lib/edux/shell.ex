defmodule Edux.Shell do
  use GenServer

  require Logger

  def start_link(websocket) do
    GenServer.start_link(__MODULE__, websocket)
  end

  def command(pid, command) do
    GenServer.cast(pid, {:command, command})
  end

  def init(websocket) do
    #    dir = Path.join(:code.priv_dir(:edux), "tmp")
    port = Port.open({:spawn, "iex"}, [:binary])
    {:ok, %{websocket: websocket, port: port}}
  end

  def handle_cast({:command, command}, state) do
    Port.command(state.port, command)
    {:noreply, state}
  end

  def handle_info({_port, {:data, msg}}, %{websocket: websocket} = state) do
    send(websocket, msg)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warning("Unexpected message received in shell: #{inspect(msg)}")
    {:noreply, state}
  end
end
