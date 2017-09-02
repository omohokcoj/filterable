defmodule Filterable.Mixfile do
  use Mix.Project

  @name "Filterable"
  @project_url "https://github.com/omohokcoj/filterable"
  @version "0.5.3"

  def project do
    [app: :filterable,
     name: @name,
     version: @version,
     elixir: "~> 1.3",
     source_url: @project_url,
     homepage_url: @project_url,
     description: description(),
     elixirc_paths: elixirc_paths(Mix.env),
     package: package(),
     deps: deps(),
     aliases: aliases(),
     docs: docs(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test,
                         "coveralls.travis": :test, "coveralls.html": :test]]
  end

  def application do
    [applications: applications(Mix.env)]
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: [:dev, :docs]},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:excoveralls, "~> 0.5", only: :test},
     {:plug, "~> 1.1.2", only: :test},
     {:postgrex, ">= 0.0.0", only: :test},
     {:ecto, "~> 2.1", only: :test},
     {:inch_ex, only: [:dev, :docs]},
     {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false}]
  end

  defp description do
    """
    Allows to map incoming query parameters to filter function with easy to use DSL inspired by Rails has_scope.
    """
  end

  defp package do
    [name: :filterable,
     files: ["lib", "mix.exs", "README*", "config"],
     maintainers: ["Pete Matsyburka"],
     licenses: ["MIT"],
     links: %{"GitHub" => @project_url,
              "Docs" => "https://hexdocs.pm/filterable"}]
  end

  defp applications(:test), do: applications() ++ ~w(postgrex ecto plug)a
  defp applications(_), do: applications()
  defp applications(), do: ~w(logger)a

  defp elixirc_paths(:test), do: elixirc_paths() ++ ~w(test/support/repo.ex)
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ~w(lib)

  defp docs do
    [main: "readme",
     source_url: @project_url,
     extras: ["README.md"]]
  end

  defp aliases do
    ["ecto.seed": "run priv/repo/seeds.exs",
     "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seed"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.reset", "test"]]
  end
end
