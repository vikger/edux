defmodule Edux.SessionManager do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def new(pid) do
    GenServer.call(__MODULE__, {:new, pid})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:new, pid}, _from, state) do
    Process.monitor(pid)
    session_id = :rand.uniform(100_000)
    Logger.info("New session #{session_id}")
    {:reply, session_id, Map.put(state, pid, session_id)}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case Map.get(state, pid) do
      nil ->
        {:noreply, state}

      session_id ->
        Logger.info("Cleanup session #{session_id}")
        File.rm("tmp_#{session_id}.ex")
        {:noreply, Map.delete(state, pid)}
    end
  end

  def handle_info(other, state) do
    Logger.warn("Unexpected message in SessionManager: #{other}")
    {:noreply, state}
  end
end
