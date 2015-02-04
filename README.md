PlugHeartbeat
=============

A tiny plug for responding to heartbeat requests.

## Installation and docs

[Documentation is available on hex.pm][docs].

Add a dependency to your application's `mix.exs` file:

```elixir
defp deps do
  [{:plug_heartbeat, "~> 0.1"}]
end
```

then run `mix deps.get`.

## Usage

Just plug this plug (sorry) in your plug pipeline:

```elixir
defmodule MyServer do
  use Plug.Builder
  plug Heartbeat
  # ... rest of the pipeline
end
```

With this setup, all `GET` and `HEAD` requests to `/heartbeat` will return a
*200 OK* status and `OK` as the body. This path can be customized through the
`:path` option:

```elixir
defmodule MyServer do
  use Plug.Builder
  plug Heartbeat, path: "/health"
  # ... rest of the pipeline
end
```

That's pretty much it, but the [docs][docs] contain further details.

## License

MIT &copy; Andrea Leopardi, see the [license file][license].


[license]: LICENSE.txt
[docs]: https://hex.pm/packages/plug_heartbeat
