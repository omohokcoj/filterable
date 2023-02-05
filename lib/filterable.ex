defmodule Filterable do
  @moduledoc """
  `Filterable` allows to map incoming parameters to filter functions.

  This module contains functions (`apply_filters/3`, `filter_values/2`)
  which allow to perform filtering and `filterable` macro which allows
  to define available filters using DSL (see `Filterable.DSL`).
  """

  alias Filterable.{Params, Utils}

  @default_options [
    allow_blank: false,
    allow_nil: false,
    trim: true,
    default: nil,
    cast: nil,
    cast_errors: true
  ]

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
      def apply_filters!(queryable, params, opts \\ []) do
        Filterable.apply_filters!(queryable, params, @filters_module, filter_options(opts))
      end

      def apply_filters(queryable, params, opts \\ []) do
        Filterable.apply_filters(queryable, params, @filters_module, filter_options(opts))
      end

      def filter_values(params, opts \\ []) do
        Filterable.filter_values(params, @filters_module, filter_options(opts))
      end

      def filter_options(opts \\ []) do
        Keyword.merge(opts, @filter_options)
      end

      defdelegate defined_filters(), to: @filters_module, as: :defined_filters

      defoverridable apply_filters!: 3,
                     apply_filters!: 2,
                     apply_filters: 3,
                     apply_filters: 2,
                     filter_values: 2,
                     filter_values: 1,
                     filter_options: 1
    end
  end

  defmacro filterable(arg, opts \\ [])
  defmacro filterable([do: block], opts), do: filterable(nil, block, opts)
  defmacro filterable(arg, do: block), do: filterable(nil, block, arg)
  defmacro filterable(arg, opts), do: filterable(arg, nil, opts)

  defmacro define_module(module, do: block) do
    quote do
      defmodule unquote(module) do
        use Filterable.DSL
        use Filterable.Ecto.Helpers
        unquote(block)
      end
    end
  end

  @spec apply!(any, map | Keyword.t(), module, Keyword.t()) :: any | no_return
  def apply!(queryable, params, module, opts \\ []) do
    case apply_filters(queryable, params, module, opts) do
      {:ok, result, _values} -> result
      {:error, message} -> raise Filterable.FilterError, message
    end
  end

  @spec apply_filters!(any, map | Keyword.t(), module, Keyword.t()) :: {any, map} | no_return
  def apply_filters!(queryable, params, module, opts \\ []) do
    case apply_filters(queryable, params, module, opts) do
      {:ok, result, values} -> {result, values}
      {:error, message} -> raise Filterable.FilterError, message
    end
  end

  @spec apply_filters(any, map | Keyword.t(), module, Keyword.t()) ::
          {:ok, any, map} | {:error, String.t()}
  def apply_filters(queryable, params, module, opts \\ []) do
    with {:ok, values} <- filter_values(params, module, opts),
         {:ok, result} <- filters_result(queryable, values, module, opts),
         do: {:ok, result, values}
  end

  @spec filter_values(map | Keyword.t(), module, Keyword.t()) :: {:ok, map} | {:error, String.t()}
  def filter_values(params, module, opts \\ []) do
    Utils.reduce_with(module.defined_filters, %{}, fn {filter_name, filter_opts}, acc ->
      options =
        [param: filter_name]
        |> Keyword.merge(@default_options)
        |> Keyword.merge(filter_opts)
        |> Keyword.merge(opts)

      case Params.filter_value(params, options) do
        {:ok, nil} -> acc
        {:ok, val} -> Map.put(acc, filter_name, val)
        error = {:error, _} -> error
      end
    end)
  end

  defp filters_result(queryable, filter_values, module, opts) do
    Utils.reduce_with(module.defined_filters, queryable, fn {filter_name, filter_opts},
                                                            queryable ->
      options = Keyword.merge(opts, filter_opts)
      value = Map.get(filter_values, filter_name)

      share = Keyword.get(options, :share)
      allow_nil = Keyword.get(options, :allow_nil)
      has_value = value != nil

      try do
        cond do
          (allow_nil || has_value) && share ->
            apply(module, filter_name, [queryable, value, share])

          allow_nil || has_value ->
            apply(module, filter_name, [queryable, value])

          true ->
            queryable
        end
      rescue
        FunctionClauseError -> queryable
      end
    end)
  end

  defp filterable(module, block, opts) do
    quote do
      @filter_options unquote(opts)
      @filters_module unquote(module) || Module.concat([__MODULE__, Filterable])

      if unquote(is_tuple(block)) do
        Filterable.define_module(@filters_module, do: unquote(block))
      end
    end
  end
end
