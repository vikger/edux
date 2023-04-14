defmodule EduxTest do
  use ExUnit.Case
  doctest Edux

  test "greets the world" do
    assert Edux.hello() == :world
  end
end
