defmodule Blitzy.Mixfile do
  use Mix.Project

  def project do
    [app: :blitzy,
     version: "0.0.1",
     elixir: "~> 1.0",
     escript: escript,
     deps: deps]
  end

  def escript do
    [main_module: Blitzy.CLI]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [ 
      {:httpoison, "~> 0.5"},
      {:timex,     "~> 0.13.1"} 
    ]
  end
end
