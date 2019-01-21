defmodule Filterable.UserFilters do
  @moduledoc false

  use Filterable.DSL
  use Filterable.Ecto.Helpers

  import Ecto.Query

  field :name
  field :subscribed

  orderable [:name, :surname]
  paginateable per_page: 4

  @options cast: :integer, share: false
  filter age(query, value) when value < 120 do
    query |> where(age: ^value)
  end

  @options cast: :date
  filter birthday(query, value, _) do
    query |> where(birthday: ^value)
  end

  @options cast: :integer
  filter position(query, %{lat: lat, lng: lng}, _) do
    from(
      q in query,
      where:
        fragment("round(?[1]) = ?", q.latlng, ^lat) and
          fragment("round(?[2]) = ?", q.latlng, ^lng)
    )
  end
end
