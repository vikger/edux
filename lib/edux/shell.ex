defmodule Edux.Shell do
  use GenServer

  def start_link(websocket) do
    GenServer.start_link(__MODULE__, websocket)
  end

  def command(pid, command) do
    GenServer.cast(pid, {:command, command})
  end

  def init(websocket) do
    port = Port.open({:spawn, "iex"}, [:binary])
    {:ok, %{websocket: websocket, port: port}}
  end

  def handle_cast({:command, command}, state) do
    Port.command(state.port, command)
    {:noreply, state}
  end

  def handle_info({_port, {:data, msg}}, %{websocket: websocket} = state) do
    IO.inspect(msg)
    send(websocket, msg)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end
end
