defmodule Filterable.UserModelFilters do
  use Filterable.DSL

  import Ecto.Query

  filter name(query, value, _share) do
    query |> where(name: ^value)
  end

  @options cast: :integer
  filter age(query, value, _share) when value < 120 do
    query |> where(age: ^value)
  end
end
