# Filterable

[![Build Status](https://travis-ci.org/omohokcoj/filterable.svg?branch=master)](https://travis-ci.org/omohokcoj/filterable)
[![Code Climate](https://codeclimate.com/github/omohokcoj/filterable/badges/gpa.svg)](https://codeclimate.com/github/omohokcoj/filterable)
[![Coverage Status](https://coveralls.io/repos/github/omohokcoj/filterable/badge.svg?branch=master)](https://coveralls.io/github/omohokcoj/filterable?branch=master)
[![Inline docs](http://inch-ci.org/github/omohokcoj/filterable.svg?branch=master)](http://inch-ci.org/github/omohokcoj/filterable)
[![Hex.pm](https://img.shields.io/hexpm/v/filterable.svg)](https://hex.pm/packages/filterable)

Filterable allows to map incoming query parameters to filter functions.
The goal is to provide minimal and easy to use DSL for building composable queries using incoming parameters.
Filterable doesn't depend on external libraries or frameworks and can be used in Phoenix or pure Elixir projects.
Inspired by [has_scope](https://github.com/plataformatec/has_scope).

## Installation

Add `filterable` to your mix.exs.

```elixir
{:filterable, "~> 0.5.2"}
```

## Usage

### Phoenix controller

Put `use Filterable.Phoenix.Controller` inside Phoenix controller or add it to `web.ex`.
It will extend controller module with `filterable` macro which allows to define filters.
Then use `apply_filters` function inside controller action to filter using defined filters:

```elixir
defmodule MyApp.PostController do
  use MyApp.Web, :controller
  use Filterable.Phoenix.Controller

  filterable do
    filter author(query, value, _conn) do
      query |> where(author_name: ^value)
    end

    @options param: :q
    filter search(query, value, _conn) do
      query |> where([u], ilike(u.title, "%#{value}%"))
    end

    @options cast: :integer
    filter year(query, value, _conn) do
      query |> where(author_name: ^value)
    end
  end

  # /posts?q=castle&author=Kafka&year=1926
  def index(conn, params) do
    with {:ok, query, filter_values} <- apply_filters(Post, conn),
         posts                       <- Repo.all(query),
     do: render(conn, "index.json", posts: posts, meta: filter_values)
  end
end
```

If you prefer to handle errors with exceptions then use `apply_filters!`:

```elixir
def index(conn, params) do
  {query, filter_values} = apply_filters!(Post, conn)
  render(conn, "index.json", posts: Repo.all(posts), meta: filter_values)
end
```

### Phoenix model

Put `use Filterable.Phoenix.Model` inside Ecto model module and define filters using `filterable` macro:

```elixir
defmodule MyApp.Post do
  use MyApp.Web, :model
  use Filterable.Phoenix.Model

  filterable do
    filter author(query, value, _conn) do
      query |> where(author_name: ^value)
    end
  end

  schema "posts" do
    ...
  end
end
```

Then call `apply_filters` function from model module:

```elixir
# /posts?author=Tom
def index(conn, params, conn) do
  with {:ok, query, filter_values} <- Post.apply_filters(conn),
       posts                       <- Repo.all(query),
   do: render(conn, "index.json", posts: posts, meta: filter_values)
end
```

### Separate module

Filters could be defined in separate module, just `use Filterable.DSL` inside module to make it filterable:

```elixir
defmodule PostFilters do
  use Filterable.DSL
  use Filterable.Phoenix.Helpers

  field :author
  field :title

  paginateable per_page: 10

  @options param: :q
  filter search(query, value, _conn) do
    query |> where([u], ilike(u.title, "%#{value}%"))
  end

  @options cast: :integer
  filter year(query, value, _conn) do
    query |> where(author_name: ^value)
  end
end

defmodule MyApp.PostController do
  use MyApp.Web, :controller
  use Filterable.Phoenix.Controller

  filterable PostFilters

  # /posts?q=castle&author=Kafka&year=1926
  def index(conn, params) do
    with {:ok, query, filter_values} <- apply_filters(Post, conn),
         posts                       <- Repo.all(query),
     do: render(conn, "index.json", posts: posts, meta: filter_values)
  end
end
```

## Defining filters

Each defined filter can be tuned with `@options` module attribute.
Just set `@options` attribute before filter definition. Available options are:

`:param` - allows to set query parameter name, by default same as filter name. Accepts `Atom`, `List`, and `Keyword` values:

```elixir
# /posts?q=castle
# => #Ecto.Query<from p in Post, where: ilike(u.title, ^"%castle%")>
@options param: :q
filter search(query, value, _conn) do
  query |> where([u], ilike(u.title, ^"%#{value}%"))
end

# /posts?sort=name&order=desc
# => #Ecto.Query<from p in Post, order_by: [desc: p.name]>
@options param: [:sort, :order], cast: :integer
filter search(query, %{sort: field, order: order}, _conn) do
  query |> order_by([{^order, ^field}])
end

# /posts?sort[field]=name&sort[order]=desc
# => #Ecto.Query<from p in Post, order_by: [desc: p.name]>
@options param: [sort: [:field, :order]], cast: :integer
filter search(query, %{field: field, order: order}, _conn) do
  query |> order_by([{^order, ^field}])
end
```

`:default` - allows to set default filter value:

```elixir
# /posts
# => #Ecto.Query<from p in Post, limit: 20>
@options default: 20, cast: integer
filter limit(query, value, _conn) do
  query |> limit(^value)
end

# /posts
# => #Ecto.Query<from p in Post, order_by: [desc: p.inserted_at]>
@options param: [:sort, :order], default: [sort: :inserted_at, order: :desc], cast: :atom
filter search(query, %{sort: field, order: order}, _conn) do
  query |> order_by([{^order, ^field}])
end
```

`:allow_blank` - when `true` then it allows to trigger filter with blank value (`""`, `[]`, `{}`, `%{}`). `false` by default, so all blank values will be converted to `nil`:

```elixir
# /posts?title=""
# => #Ecto.Query<from p in Post>
@options allow_blank: false
filter title(query, value, _conn) do
  query |> where(title: ^value)
end

# /posts?title=""
# => #Ecto.Query<from p in Post, where: p.title == "">
@options allow_blank: true
filter title(query, value, _conn) do
  query |> where(title: ^value)
end
```

`:allow_nil` - when `true` then it allows to trigger filter with `nil` value, `false` by default:

```elixir
# /posts?title=""
# => #Ecto.Query<from p in Post, where: is_nil(p.title)>
# /posts?title=Casle
# => #Ecto.Query<from p in Post, where: p.title == "Casle">
@options allow_nil: true
filter title(query, nil, _conn) do
  query |> where([q], is_nil(q.title))
end
filter title(query, value, _conn) do
  query |> where(title: ^value)
end
```

`:trim` - allows to remove leading and trailing whitespaces from string values, `true` by default:

```elixir
# /posts?title="   Casle  "
# => #Ecto.Query<from p in Post, where: p.title == "Casle">
filter title(query, value, _conn) do
  query |> where(title: ^value)
end

# /posts?title="   Casle  "
# => #Ecto.Query<from p in Post, where: p.title == "   Casle  ">
@options trim: false
filter title(query, value, _conn) do
  query |> where(title: ^value)
end
```

`:cast` - allows to convert value to specific type. Available types are: `integer`, `float`, `string`, `atom`, `boolean`, `date`, `datetime`. Also can accept pointer to function:

```elixir
# /posts?limit=20
# => #Ecto.Query<from p in Post, limit: 20>
@options cast: :integer
filter limit(query, value, _conn) do
  query |> limit(^value)
end

# /posts?title=Casle
# => #Ecto.Query<from p in Post, where: p.title == "casle">
@options cast: &String.downcase/1
filter title(query, value, _conn) do
  query |> where(title: ^value)
end
```

`:cast_errors` - accepts `true` (default) or `false`. If `true` then it returns error if value can't be caster to specific type. If `false` - it skips filter if filter value can't be casted:

```elixir
# /posts?inserted_at=Casle
# => {:error, "Unable to cast \"Casle\" to datetime"}
@options cast: :datetime
filter inserted_at(query, value, _conn) do
  query |> where(inserted_at: ^value)
end

# /posts?inserted_at=Casle
# => #Ecto.Query<from p in Post>
@options cast: :datetime, cast_errors: false
filter inserted_at(query, value, _conn) do
  query |> where(inserted_at: ^value)
end
```

`:share` - allows to set shared value. When `false` then filter function will be triggered without shared value argument:

```elixir
@options share: false
filter title(query, value) do
  query |> where(title: ^value)
end
```

All these options can be specified in `apply_filters` function or `filterable` macro. Then they will take affect on all defined filters:

```elixir
filterable share: false, cast_errors: false do
  field :title
end

# or

filterable PostFilters, share: false, cast_errors: false

# or

{:ok, query, filter_values} = apply_filters(conn, share: false, cast_errors: false)
```

## Phoenix helpers

`Filterable.Phoenix.Helpers` module provides macros which allows to define some popular filters:

`field/2` - expands to simple `Ecto.Query.where` filter:

```elixir
filterable do
  field :title
  field :stars, cast: :integer
end
```

Same filters could be built with `filter` macro:

```elixir
filterable do
  filter title(query, value, _conn) do
    query |> where(title: ^value)
  end

  @options cast: :integer
  filter stars(query, value, _conn) do
    query |> where(stars: ^value)
  end
end
```

`paginateable/1` - provides pagination logic, Default amount of records per page could be tuned with `per_page` option. By default it's set to 20:

```elixir
filterable do
  # /posts?page=3
  # => #Ecto.Query<from p in Post, limit: 10, offset: 20>
  paginateable per_page: 10
end
```

`limitable/1` - provides limit/offset logic:

```elixir
filterable do
  # /posts?limit=3offset=10
  # => #Ecto.Query<from p in Post, limit: 3, offset: 10>
  limitable limit: 10
end
```

`orderable/1` - provides sorting logic, accepts list of atoms:

```elixir
filterable do
  # /posts?sort=inserted_at&order=asc
  # => #Ecto.Query<from p in Post, order_by: [asc: p.inserted_at]>
  orderable [:title, :inserted_at]
end
```

## Common usage

`Filterable` also can be used in non Ecto/Phoenix projects.
Put `use Filterable.DSL` inside module to start defining filters:

```elixir
defmodule RepoFilters do
  use Filterable.DSL

  filter name(list, value) do
    list |> Enum.filter(& &1.name == value)
  end

  @options cast: :integer
  filter stars(list, value) do
    list |> Enum.filter(& &1.stars >= value)
  end
end
```

Then filter collection using `apply_filters` function:

```elixir
repos = [%{name: "phoenix", stars: 8565}, %{name: "ecto", start: 2349}]

{:ok, result, filter_values} = RepoFilters.apply_filters(repos, %{name: "phoenix", stars: "8000"})
# or
{:ok, result, filter_values} = Filterable.apply_filters(repos, %{name: "phoenix", stars: "8000"}, RepoFilters)
```

## Similar packages:
- [filterex](https://github.com/rcdilorenzo/filtrex)
- [rumage_ecto](https://github.com/Excipients/rummage_ecto)
- [inquisitor](https://github.com/DockYard/inquisitor)
- [ex_sieve](https://github.com/valyukov/ex_sieve)

## TODO:

- [X] Coverage 100%
- [X] Better README
- [ ] Documentation
- [X] Improve tests

## Contribution

Feel free to send your PR with proposals, improvements or corrections 😉
