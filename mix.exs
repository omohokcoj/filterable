defmodule Filterable.Mixfile do
  use Mix.Project

  def project do
    [app: :filterable,
     version: "0.0.4",
     elixir: "~> 1.2",
     description: description(),
     package: package(),
     deps: deps(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     docs: &docs/0
   ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: :dev},
     {:credo, "~> 0.5", only: [:dev, :test]}]
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
