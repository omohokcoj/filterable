defmodule Filterable do
  alias Filterable.Params

  @default_options [allow_blank: false, allow_nil: false, trim: true, default: nil, cast: nil]

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [filterable: 2, filterable: 1]

      @before_compile unquote(__MODULE__)
      @filters_module __MODULE__
      @filter_options []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def apply_filters(queryable, params, opts \\ []) do
        options = Keyword.merge(opts, @filter_options)
        Filterable.apply_filters(queryable, params, @filters_module, options)
      end

      def filter_values(params, opts \\ []) do
        options = Keyword.merge(opts, @filter_options)
        Filterable.filter_values(params, @filters_module, options)
      end

      defoverridable [apply_filters: 3, apply_filters: 2, filter_values: 2, filter_values: 1]
    end
  end

  defmacro filterable(arg, opts \\ [])
  defmacro filterable([do: block], opts) do
    __filterable__(nil, block, opts)
  end
  defmacro filterable(arg, do: block) do
    __filterable__(nil, block, arg)
  end
  defmacro filterable(arg, opts) do
    __filterable__(arg, nil, opts)
  end

  def apply_filters(queryable, params, module, opts \\ []) do
    values = filter_values(params, module, opts)

    module.defined_filters
    |> Enum.reduce(queryable, fn ({filter_name, filter_opts}, queryable) ->
      options = Keyword.merge(opts, filter_opts)

      share     = Keyword.get(options, :share)
      allow_nil = Keyword.get(options, :allow_nil)

      value = Map.get(values, filter_name)

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
    |> Enum.reduce(%{}, fn ({filter_name, filter_opts}, acc) ->
      options =
        [param: filter_name]
        |> Keyword.merge(@default_options)
        |> Keyword.merge(filter_opts)
        |> Keyword.merge(opts)

      case Params.filter_value(params, options) do
        nil -> acc
        val -> Map.put(acc, filter_name, val)
      end
    end)
  end

  defp __filterable__(module, block, opts) do
    quote do
      @filter_options unquote(opts)
      @filters_module unquote(module) || Module.concat([__MODULE__, Filterable])

      unless unquote(module) do
        defmodule @filters_module do
          use Filterable.DSL
          unquote(block)
        end
      end
    end
  end
end
