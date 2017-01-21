# Filterable

Filterable allows to map incoming parameters to filter functions.
The goal is to provide minimal DSL for building filters using mostly pure elixir syntax.
Inspired by [has_scope](https://github.com/plataformatec/has_scope). 
See phoenix usage at [filterable_phoenix](https://github.com/omohokcoj/filterable_phoenix)

## Installation

Add `filterable` to your mix.exs.

```elixir
{:filterable, "~> 0.1.0"}
```

## Usage

Common usage:

```elixir
defmodule UserFilters do
  use Filterable.DSL

  filter name(list, value) do
    list |> Enum.filter(&(&1.name == value))
  end
end

users = [%{name: "Tom"},
         %{name: "Jony"}]

UserFilters.apply_filters(users, %{name: "Tom"})
```

## Contribution

Feel free to send your PR with proposals, improvements or corrections!
