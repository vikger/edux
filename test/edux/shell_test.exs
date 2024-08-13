defmodule Edux.ShellTest do
  use ExUnit.Case

  import Mock

  test "send, receive" do
    with_mock Edux.Shell, [:passthrough],
      open_shell: fn -> nil end,
      shell_command: fn _, command -> send(self(), {nil, {:data, command}}) end do
      {:ok, shell} = Edux.Shell.start_link(self())
      command = "abc\n"
      Edux.Shell.command(shell, command)

      received =
        receive do
          msg -> msg
        end

      assert received == command
    end
  end
end
