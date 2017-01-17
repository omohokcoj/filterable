# Filterable

Filterable allows to map incoming controller parameters to filter functions.

## Installation

Add `filterable` to your mix.exs.

```elixir
{:filterable, "~> 0.0.2"}
```

Then `use` Filterable module inside controller or make it available for all application controllers by adding it to `web.ex`:

```elixir
  def controller do
    quote do
      use Phoenix.Controller
      use Filterable

      ...
    end
  end
```

## Usage

Common usage:

```elixir
defmodule Application.PostController do
  use MyApp.Web, :controller
  use Filterable

  alias MyApp.Post

  defmodule Filterable do
    def title(_conn, query, value) do
      query |> where(title: ^value)
    end
  end

  def index(conn, params) do
    posts = Post |> apply_filters(conn) |> Repo.all
    render(conn, "index.html", posts: posts)
  end
end
```

By default `apply_filters` uses filter functions defined in `ControllerModule.Filterable` module.
Lets define some complex filters in separate module:

```elixir
defmodule AvailableFilters do
  def title(_, query, value) do
    query |> where(title: ^value)
  end

  def condition(_, query, value) when value in ~w(published archived) do
    query |> where(condition: ^value)
  end

  def author(conn, query, value) when value == "current_user" do
    query |> where(author_id: ^current_user(conn).id)
  end
  def author(_, query, value) do
    query |> where(author_name: ^value)
  end
end
```

Then we can link filter functions from this module by calling `filterable` macro inside controller:

```elixir
defmodule Application.PostController do
  ...

  filterable AvailableFilters

  def index(conn, params) do
    posts = Post |> apply_filters(conn) |> Repo.all
    render(conn, "index.html", posts: posts)
  end
end
```

Also we can specify top level filters query param with `filterable` marco:

```elixir
  filterable AvailableFilters, param: "filter"
```

This could be useful for working with [json-api](http://jsonapi.org/format/#fetching-filtering) filters query.

## Contribution

Feel free to send your PR with proposals, improvements or corrections!
