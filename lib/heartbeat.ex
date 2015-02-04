defmodule Heartbeat do
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

  ## Examples

      defmodule MyServer do
        use Plug.Builder
        plug Heartbeat

        # ... rest of the pipeline
      end

  Using a custom heartbeat path is easy:

      defmodule MyServer do
        use Plug.Builder
        plug Heartbeat, path: "/health"

        # ... rest of the pipeline
      end

  """

  @behaviour Plug
  import Plug.Conn


  def init([]), do: [path: @default_path]
  def init([path: _path] = opts), do: opts

  def call(%Plug.Conn{} = conn, opts) do
    if full_path(conn) == opts[:path] and conn.method in ["GET", "HEAD"] do
      conn |> halt |> send_resp(200, "OK")
    else
      conn
    end
  end
end
