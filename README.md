# Filterable [![Build Status](https://travis-ci.org/omohokcoj/filterable.svg?branch=master)](https://travis-ci.org/omohokcoj/filterable) [![Code Climate](https://codeclimate.com/github/omohokcoj/filterable/badges/gpa.svg)](https://codeclimate.com/github/omohokcoj/filterable) [![Coverage Status](https://coveralls.io/repos/github/omohokcoj/filterable/badge.svg?branch=master)](https://coveralls.io/github/omohokcoj/filterable?branch=master)

Filterable allows to map incoming parameters to filter functions.
The goal is to provide minimal and easy to use DSL for building filters using pure elixir.
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
    list |> Enum.filter &(&1.name == value)
  end
end

users = [%{name: "Tom", age: 23}, %{name: "Jony", age: 24}]

UserFilters.apply_filters(users, %{name: "Tom", age: 24})
```

## Contribution

Feel free to send your PR with proposals, improvements or corrections!
