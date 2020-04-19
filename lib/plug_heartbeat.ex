defmodule PlugHeartbeat do
  @default_path "/heartbeat"

  @moduledoc """
  A plug for responding to heartbeat requests.

  This plug responds with a successful status to `GET` or `HEAD` requests at a
  specific path so that clients can check if a server is alive.

  The response that this plug sends is a *200 OK* response with body `OK`. By
  default, the path that responds to the heartbeat is `#{@default_path}`, but it
  can be configured.

  Note that this plug **halts the connection**. This is done so that it can be
  plugged near the top of a plug pipeline and catch requests early so that
  subsequent plugs don't have the chance to tamper the connection.
  Read more about halting connections in the [docs for
  `Plug.Builder`](http://hexdocs.pm/plug/Plug.Builder.html).

  ## Options

  The following options can be used when calling `plug PlugHeartbeat`.

    * `:path` - a string expressing the path on which `PlugHeartbeat` will be mounted to
      respond to heartbeat requests
    * `:json` - a boolean which determines whether the response will be an
      `application/json` response (if `true`) or a regular response.

  ## Examples

      defmodule MyServer do
        use Plug.Builder
        plug PlugHeartbeat

        # ... rest of the pipeline
      end

  Using a custom heartbeat path is easy:

      defmodule MyServer do
        use Plug.Builder
        plug PlugHeartbeat, path: "/health"

        # ... rest of the pipeline
      end

  """

  @behaviour Plug
  import Plug.Conn

  def init(opts),
    do: Keyword.merge([path: @default_path, json: false], opts)

  def call(%Plug.Conn{} = conn, opts) do
    if conn.request_path == opts[:path] and conn.method in ~w(GET HEAD) do
      conn |> halt |> send_beat(opts[:json])
    else
      conn
    end
  end

  defp send_beat(conn, false = _json),
    do: send_resp(conn, 200, "OK")

  defp send_beat(conn, true = _json),
    do: conn |> put_resp_content_type("application/json") |> send_resp(200, "{}")
end
