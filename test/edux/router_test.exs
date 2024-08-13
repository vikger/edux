defmodule Edux.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias Edux.Router

  @options Router.init([])

  test "index.html" do
    assert {200, _, "<html>" <> _} = get("/")
  end

  test "index.js" do
    assert {200, _, "" <> _} = get("/js/index.js")
  end

  test "main.css" do
    assert {200, _, "html, body" <> _} = get("/css/main.css")
  end

  test "get invalid path" do
    assert {404, _, "not found"} = get("/invalid_path")
  end

  test "post not found" do
    assert {404, _, "not found"} =
             conn(:post, "/")
             |> Router.call(@options)
             |> sent_resp()
  end

  defp get(path) do
    conn(:get, path)
    |> Router.call(@options)
    |> sent_resp()
  end
end
