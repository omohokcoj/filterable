defmodule Filterable.UserFilters do
  use Filterable.DSL

  import Ecto.Query

  @options share: false
  filter name(query, value) do
    query |> where(name: ^value)
  end

  @options cast: :integer, share: false
  filter age(query, value) when value < 120 do
    query |> where(age: ^value)
  end

  @options cast: :date!
  filter birthday(query, value, _share) do
    query |> where(birthday: ^value)
  end

  @options params: :position, param: [:lat, :lng], cast: :integer
  filter position(query, %{lat: lat, lng: lng}, _share) when not is_nil(lat) and not is_nil(lng) do
    from q in query,
           where: fragment("round(?[1]) = ?", q.latlng, ^lat)
           and fragment("round(?[2]) = ?", q.latlng, ^lng)
  end

  @options param: [:page, :per_page], default: [page: 1, per_page: 4], cast: :integer
  filter paginate(_query, %{page: page, per_page: _}, _share) when page < 0 do
    raise Filterable.InvalidParamError, message: "Page can't be negative"
  end
  filter paginate(_query, %{page: _page, per_page: per_page}, _share) when per_page < 0 do
    raise Filterable.InvalidParamError, message: "Per page can't be negative"
  end
  filter paginate(_query, %{page: _page, per_page: per_page}, _share) when per_page > 5 do
    raise Filterable.InvalidParamError, message: "Per page can't more than 5"
  end
  filter paginate(query, %{page: page, per_page: per_page}, _share) do
    query |> limit(^per_page) |> offset(^((page - 1) * per_page))
  end
end
