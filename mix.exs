defmodule Filterable.Mixfile do
  use Mix.Project

  @project_url "https://github.com/omohokcoj/filterable"
  @version "0.1.3"

  def project do
    [app: :filterable,
     version: @version,
     elixir: "~> 1.3",
     description: description(),
     source_url: @project_url,
     homepage_url: @project_url,
     package: package(),
     deps: deps(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.travis": :test, "coveralls.html": :test],
     docs: docs()
   ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: :dev},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:excoveralls, "~> 0.5", only: :test}]
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

  defp docs do
    {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
    [source_ref: ref,
     main: "readme",
     extras: ["README.md"]]
  end
end
