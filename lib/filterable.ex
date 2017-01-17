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

  Also can be used as raw function:

      def index(conn, params) do
        posts = Post |> Filterable.apply_filters(conn, FiltersModule) |> Repo.all
        render(conn, "index.html", posts: posts)
      end
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

  @doc false
  defmacro __before_compile__(_) do
    quote do
      def apply_filters(query, conn) do
        unquote(__MODULE__).apply_filters(query, conn, @filters_module, @filter_options)
      end
    end
  end

  @doc """
  Allows to select `module` with defined filter functions with options.

  ## Options

    * `:param` - Sets top level query param for filters.
  """
  defmacro filterable(module, opts \\ []) do
    quote do
      @filters_module unquote(module)
      @filter_options unquote(opts)
    end
  end

  @doc """
  Applies filters on `query` using filter function defined in `module`
  """
  def apply_filters(query, conn, module, opts \\ []) do
    params_key = Keyword.get(opts, :param)
    defined_filters = module.__info__(:functions)

    Enum.reduce(defined_filters, query, fn ({filter_name, args_num}, query) ->
      param_name = Atom.to_string(filter_name)
      value = conn.params |> Map.get(params_key, %{}) |> Map.get(param_name)
      try do
        cond do
          args_num == 2 && !value ->
            apply(module, filter_name, [conn, query])
          args_num == 3 && value ->
            apply(module, filter_name, [conn, query, value])
          true -> query
        end
      rescue
        FunctionClauseError -> query
      end
    end)
  end
end
