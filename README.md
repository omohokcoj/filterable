# Filterable

[![Build Status](https://travis-ci.org/omohokcoj/filterable.svg?branch=master)](https://travis-ci.org/omohokcoj/filterable)
[![Code Climate](https://codeclimate.com/github/omohokcoj/filterable/badges/gpa.svg)](https://codeclimate.com/github/omohokcoj/filterable)
[![Coverage Status](https://coveralls.io/repos/github/omohokcoj/filterable/badge.svg?branch=master)](https://coveralls.io/github/omohokcoj/filterable?branch=master)
[![Inline docs](http://inch-ci.org/github/omohokcoj/filterable.svg?branch=master)](http://inch-ci.org/github/omohokcoj/filterable)

Filterable allows to map incoming parameters to filter functions.
The goal is to provide minimal and easy to use DSL for building filters using pure Elixir.
Filterable doesn't depend on external libraries or frameworks and can be used both in Phoenix and pure Elixir projects.
Inspired by [has_scope](https://github.com/plataformatec/has_scope).

## Installation

Add `filterable` to your mix.exs.

```elixir
{:filterable, "~> 0.1.6"}
```

## Usage

Common usage:

```elixir
defmodule RepoFilters do
  use Filterable.DSL

  filter name(list, value) do
    list |> Enum.filter(& &1.name == value)
  end

  filter stars(list, value) do
    list |> Enum.filter(& &1.stars >= value)
  end
end

repos = [%{name: "phoenix", stars: 8565}, %{name: "ecto", start: 2349}]

RepoFilters.apply_filters(repos, %{name: "phoenix", stars: 8000})
```

Phoenix usage:

```elixir
defmodule MyApp.PostController do
  use MyApp.Web, :controller
  use Filterable.DSL

  @options allow_nil: true
  filter author(query, value, current_user) when is_nil(value) do
    query |> where(author_id: ^current_user.id)
  end
  filter author(query, value, _current_user) do
    query |> where(author_name: ^value)
  end

  def index(conn, params, current_user) do
    posts = Post |> apply_filters(params, share: current_user) |> Repo.all
    render(conn, "index.json-api", data: posts)
  end
end
```

## TODO:

- [ ] Coverage 100%
- [ ] Update README
- [ ] Documentation
- [ ] Improve tests

## Contribution

Feel free to send your PR with proposals, improvements or corrections!
