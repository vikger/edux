defmodule Edux.MixProject do
  use Mix.Project

  def project do
    [
      app: :edux,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Edux.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
