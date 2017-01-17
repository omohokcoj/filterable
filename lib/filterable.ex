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

  By default `apply_filters` uses filter functions defined in `AppName.ControllerModule.Filterable` module.
  Other module can be set explicitly with `filterable` macro:

      filterable UserFilters, param: "filter"
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)
      @filters_module Module.concat([__MODULE__, unquote(__MODULE__)])
      @filter_options []
    end
  end

  @lint false
  @doc false
  defmacro __before_compile__(_) do
    quote do
      def apply_filters(query, conn) do
        defined_filters = @filters_module.__info__(:functions)

        Enum.reduce(defined_filters, query, fn ({filter_name, args_num}, query) ->
          param_name = Atom.to_string(filter_name)
          value = conn |> filter_params |> Map.get(param_name)
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

      def filter_params(%{params: params}) do
        case Keyword.get(@filter_options, :param) do
          nil -> params
          key -> Map.get(params, key, %{})
        end
      end
    end
  end

  @doc """
  Allows to select `module` with defined filter functions with options.

  ## Options

    * `:param` - Sets top level query param for filters.
  """
  defmacro filterable(module, options \\ []) do
    quote do
      @filters_module unquote(module)
      @filter_options unquote(options)
    end
  end
end
