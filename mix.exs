defmodule PlugHeartbeat.Mixfile do
  use Mix.Project

  @version "1.0.0"
  @github_url "https://github.com/whatyouhide/plug_heartbeat"
  @description "A tiny plug for responding to heartbeat requests"

  def project do
    [
      app: :plug_heartbeat,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),
      description: @description,
      name: "PlugHeartbeat",
      source_url: @github_url,
      package: package()
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [
      {:plug, "~> 1.0"},
      {:ex_doc, "~> 0.21", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Andrea Leopardi"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
