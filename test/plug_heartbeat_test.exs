defmodule PlugHeartbeatTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule DefaultPath do
    use Plug.Router
    plug PlugHeartbeat
    plug :match
    plug :dispatch
    match _, do: send_resp(conn, 200, "match")
  end

  defmodule CustomPath do
    use Plug.Router
    plug PlugHeartbeat, path: "/custom-beat"
    plug :match
    plug :dispatch
    match _, do: send_resp(conn, 200, "match")
  end

  defmodule Halted do
    use Plug.Router
    plug PlugHeartbeat
    plug :match
    plug :dispatch
    plug :body_after

    defp body_after(conn, _opts), do: %{conn | resp_body: "after"}

    match _, do: send_resp(conn, 200, "match")
  end

  defmodule JSON do
    use Plug.Router
    plug PlugHeartbeat, json: true
    plug :match
    plug :dispatch
    match _, do: send_resp(conn, 200, "match")
  end

  test "default path" do
    conn = conn(:get, "/heartbeat") |> DefaultPath.call([])
    assert conn.status == 200
    assert conn.resp_body == "OK"
    refute conn.resp_body == "after"
  end

  test "the connection is halted after the heartbeat (by default)" do
    conn = conn(:get, "/heartbeat") |> Halted.call([])
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "custom path" do
    conn = conn(:get, "/custom-beat") |> CustomPath.call([])
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "HEAD requests" do
    conn = conn(:head, "/heartbeat") |> DefaultPath.call([])
    assert conn.status == 200
    assert conn.resp_body == ""
  end

  test "only GET and HEAD requests work" do
    Enum.each [:post, :put, :delete, :options, :foo], fn(method) ->
      conn = conn(method, "/heartbeat") |> DefaultPath.call([])
      assert conn.resp_body == "match"
    end
  end

  test "JSON heartbeat" do
    conn = conn(:get, "/heartbeat") |> JSON.call([])
    assert conn.resp_body == "{}"
    assert (conn |> get_resp_header("content-type") |> hd) =~ "application/json"
  end

  test "only matching requests are halted" do
    conn = conn(:get, "/passthrough") |> DefaultPath.call([])
    assert conn.status == 200
    assert conn.resp_body == "match"

    conn = conn(:get, "/passthrough") |> CustomPath.call([])
    assert conn.status == 200
    assert conn.resp_body == "match"
  end
end
