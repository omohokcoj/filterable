defmodule Filterable do
  alias Filterable.Params

  @default_options [allow_blank: false, allow_nil: false, trim: true, default: nil, cast: nil]

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)
      @filters_module __MODULE__
      @filter_options []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def apply_filters(queryable, params, opts \\ []) do
        options = Keyword.merge(opts, @filter_options)
        apply_filters(queryable, params, @filters_module, options)
      end

      def filter_values(params, opts \\ []) do
        options = Keyword.merge(opts, @filter_options)
        filter_values(params, @filters_module, options)
      end
    end
  end

  defmacro filterable(module, opts \\ []) do
    quote do
      @filters_module unquote(module)
      @filter_options unquote(opts)
    end
  end

  def apply_filters(queryable, params, module, opts \\ []) do
    values = filter_values(params, module, opts)

    module.defined_filters
    |> Enum.reduce(queryable, fn ({filter_name, filter_opts}, queryable) ->
      options = Keyword.merge(opts, filter_opts)

      value     = Keyword.get(values, filter_name)
      share     = Keyword.get(options, :share)
      allow_nil = Keyword.get(options, :allow_nil)

      try do
        cond do
          (allow_nil || value) && share ->
            apply(module, filter_name, [queryable, value, share])
          allow_nil || value ->
            apply(module, filter_name, [queryable, value])
          true -> queryable
        end
      rescue
        FunctionClauseError -> queryable
      end
    end)
  end

  def filter_values(params, module, opts \\ []) do
    module.defined_filters
    |> Enum.reduce([], fn ({filter_name, filter_opts}, list) ->
      options =
        [param: filter_name]
        |> Keyword.merge(@default_options)
        |> Keyword.merge(filter_opts)
        |> Keyword.merge(opts)

      value = Params.filter_value(params, options)

      list ++ [{filter_name, value}]
    end)
  end
end
