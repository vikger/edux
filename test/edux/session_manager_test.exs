defmodule Edux.SessionManagerTest do
  use ExUnit.Case

  alias Edux.SessionManager

  test "new session" do
    pid = dummy_process()
    session_id = SessionManager.new(pid)
    assert pid in Map.keys(SessionManager.get_state())
    assert {:ok, _} = UUID.info(session_id)
  end

  test "session termination" do
    pid = dummy_process()
    SessionManager.new(pid)
    Process.exit(pid, :kill)
    Process.sleep(500)
    refute pid in Map.keys(SessionManager.get_state())
  end

  defp dummy_process() do
    spawn(fn -> Process.sleep(5000) end)
  end
end
