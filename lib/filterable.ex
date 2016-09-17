defmodule Filterable do
  @moduledoc """
  Filterable allows to map incoming controller parameters to filter functions:

      defmodule Filterable do
        def title(_conn, query, value) do
          query |> where(title: ^value)
        end
      end

  Then we can apply defined query params filters inside controller action:

      def index(conn, params) do
        posts = Post |> apply_filters(conn) |> Repo.all
        render(conn, "index.html", posts: posts)
      end

  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)
      @filters_module Module.concat([__MODULE__, unquote(__MODULE__)])
    end
  end

  @doc false
  defmacro __before_compile__(_) do
    quote do
      def apply_filters(query, conn) do
        defined_filters = @filters_module.__info__(:functions)

        Enum.reduce(defined_filters, query, fn ({filter_name, args_num}, query) ->
          value = conn.params[Atom.to_string(filter_name)]
          try do
            cond do
              args_num == 2 && !value ->
                apply(@filters_module, filter_name, [conn, query])
              args_num == 3 && value ->
                apply(@filters_module, filter_name, [conn, query, value])
              true -> query
            end
          rescue
            FunctionClauseError -> query
          end
        end)
      end
    end
  end

  @doc """
  Allows to select `module` with defined filter functions

      filterable AvaliableFilters

  """
  defmacro filterable(module) do
    quote do
      @filters_module unquote(module)
    end
  end
end
