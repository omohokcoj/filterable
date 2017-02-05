defmodule Filterable.UserListFilters do
  use Filterable.DSL

  filter name(list, value) do
    list |> Enum.filter(& &1.name == value)
  end

  @options cast: :integer
  filter age(list, value) when value < 120 do
    list |> Enum.filter(& &1.age == value)
  end
end
