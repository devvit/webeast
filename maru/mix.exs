defmodule Myweb.Mixfile do
  use Mix.Project

  def project do
    [app: :myweb,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    # [extra_applications: [:logger]]
    [application: [:maru, :redis_pool, :ecto, :postgrex, :httpotion], mod: {Myweb, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, ''},
      {:maru, ''},
      {:poison, ''},
      {:ecto, ''},
      {:postgrex, ''},
      {:httpotion, ''},
      {:eredis, git: "https://github.com/wooga/eredis", override: true},
      {:redis_pool, git: "https://github.com/le0pard/redis_pool"}
    ]
  end
end
