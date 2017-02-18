defmodule Filterable.UserFilters do
  use Filterable.DSL

  import Ecto.Query

  alias Filterable.InvalidParamError

  @options share: false
  filter name(query, value) do
    query |> where(name: ^value)
  end

  @options cast: :integer, share: false
  filter age(query, value) when value < 120 do
    query |> where(age: ^value)
  end

  @options cast: :date!
  filter birthday(query, value, _) do
    query |> where(birthday: ^value)
  end

  @options cast: :integer
  filter position(query, %{lat: lat, lng: lng}, _) do
    from q in query,
      where: fragment("round(?[1]) = ?", q.latlng, ^lat)
         and fragment("round(?[2]) = ?", q.latlng, ^lng)
  end

  @options param: [:page, :per_page], default: [page: 1, per_page: 4], cast: :integer
  filter paginate(_, %{page: page, per_page: _}, _) when page < 0 do
    raise InvalidParamError, "Page can't be negative"
  end
  filter paginate(_, %{page: _page, per_page: per_page}, _) when per_page < 0 do
    raise InvalidParamError, "Per page can't be negative"
  end
  filter paginate(_, %{page: _page, per_page: per_page}, _) when per_page > 5 do
    raise InvalidParamError, "Per page can't be more than 5"
  end
  filter paginate(query, %{page: page, per_page: per_page}, _) do
    from q in query, limit: ^per_page, offset: ^((page - 1) * per_page)
  end

  @options top_param: :sort, param: [:field, :order], default: [order: :desc], cast: :atom
  filter sort(_, %{field: field, order: _}, _) when not field in ~w(name surname)a do
    raise InvalidParamError, "Unable to sort on #{inspect(field)}, only name and surname allowed"
  end
  filter sort(_, %{field: _, order: order}, _) when not order in ~w(asc desc)a do
    raise InvalidParamError, "Unable to sort using #{inspect(order)}, only 'asc' and 'desc' allowed"
  end
  filter sort(query, %{field: field, order: order}, _) do
    query |> order_by([{^order, ^field}])
  end
end
