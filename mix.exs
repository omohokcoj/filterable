defmodule Filterable.Mixfile do
  use Mix.Project

  def project do
    [app: :filterable,
     version: "0.0.1",
     elixir: "~> 1.2",
     description: description,
     package: package,
     deps: deps,
     docs: &docs/0
   ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: :dev}]
  end

  defp description do
    """
    Simple query params filtering for Phoenix framework.
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
