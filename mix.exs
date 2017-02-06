defmodule Filterable.Mixfile do
  use Mix.Project

  @project_url "https://github.com/omohokcoj/filterable"
  @version "0.1.4"

  def project do
    [app: :filterable,
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
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: :dev},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:excoveralls, "~> 0.5", only: :test},
     {:plug, "~> 1.1.2", only: :test},
     {:postgrex, ">= 0.0.0", only: :test},
     {:ecto, "~> 2.1", only: :test}]
  end

  defp description do
    """
    Filterable allows to map incoming parameters to filter functions.
    """
  end

  defp package do
    [name: :filterable,
     files: ["lib", "mix.exs", "README*", "config"],
     contributors: ["Pete Matsyburka"],
     maintainers: ["Pete Matsyburka"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/omohokcoj/filterable",
              "Docs" => "https://hexdocs.pm/filterable"}]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ~w(test/support)
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ~w(lib)

  defp docs do
    [source_ref: System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"]),
     main: "readme",
     extras: ["README.md"]]
  end

  defp aliases do
    ["ecto.seed": "run priv/repo/seeds.exs",
     "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seed"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
