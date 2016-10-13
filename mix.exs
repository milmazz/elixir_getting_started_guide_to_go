defmodule ElixirGettingStartedGuide.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_getting_started_guide,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     escript: escript()]
  end

  def application do
    [applications: [:yaml_elixir]]
  end

  defp deps do
    [{:yaml_elixir, "~> 1.2"},
     {:earmark, github: "pragdave/earmark"},
     {:bupe, github: "milmazz/bupe"}]
  end

  defp escript do
    [main_module: ElixirGettingStartedGuide.CLI]
  end
end
