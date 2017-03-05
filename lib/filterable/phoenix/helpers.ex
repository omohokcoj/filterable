defmodule Filterable.Phoenix.Helpers do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro searchable(field, opts \\ []) do
    quote do
      @options unquote(opts) |> Keyword.merge(share: false)
      filter unquote(field)(query, value) do
        query |> Ecto.Query.where([{unquote(field), ^value}])
      end
    end
  end

  defmacro paginateable(opts \\ []) do
    max_per_page = Keyword.get(opts, :max_per_page, 20)

    quote do
      @options param: [:page, :per_page],
               default: [page: 1, per_page: unquote(max_per_page)],
               cast: :integer, share: false
      filter paginate(_, %{page: page, per_page: _}) when page < 0 do
        {:error, "page can't be negative"}
      end
      filter paginate(_, %{page: _page, per_page: per_page}) when per_page < 0 do
        {:error, "per_page can't be negative"}
      end
      filter paginate(_, %{page: _page, per_page: per_page}) when per_page > unquote(max_per_page) do
        {:error, "per_page can't be more than #{unquote(max_per_page)}"}
      end
      filter paginate(query, %{page: page, per_page: per_page}) do
        Ecto.Query.from q in query, limit: ^per_page, offset: ^((page - 1) * per_page)
      end
    end
  end

  defmacro orderable(fields) when is_list(fields) do
    quote do
      @options param: [:sort, :order], default: [order: :desc], cast: :atom, share: false
      filter sort(query, %{sort: nil, order: _}) do
        query
      end
      filter sort(_, %{sort: field, order: _}) when not field in unquote(fields) do
        {:error, "Unable to sort on #{inspect(field)}, only name and surname allowed"}
      end
      filter sort(_, %{sort: _, order: order}) when not order in ~w(asc desc)a do
        {:error, "Unable to sort using #{inspect(order)}, only 'asc' and 'desc' allowed"}
      end
      filter sort(query, %{sort: field, order: order}) do
        query |> Ecto.Query.order_by([{^order, ^field}])
      end
    end
  end

  defmacro limitable(opts \\ []) do
    max_limit = Keyword.get(opts, :max_limit, 20)

    quote do
      @options default: unquote(max_limit), cast: :integer, share: false
      filter limit(_, value) when value < 0 do
        {:error, "limit can't be negative"}
      end
      filter limit(_, value) when value > unquote(max_limit) do
        {:error, "limit can't be more than #{unquote(max_limit)}"}
      end
      filter limit(query, value) do
        query |> Ecto.Query.limit(^value)
      end

      @options default: 0, cast: :integer, share: false
      filter offset(_, value) when value < 0 do
        {:error, "offset can't be negative"}
      end
      filter offset(query, value) do
        query |> Ecto.Query.offset(^value)
      end
    end
  end
end
