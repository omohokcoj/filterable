defmodule Filterable.DSL do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)
      @filters []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def apply_filters(queryable, params, opts \\ []) do
        Filterable.apply_filters(queryable, params, __MODULE__, opts)
      end

      def filter_values(params, opts \\ []) do
        Filterable.filter_values(params, __MODULE__, opts)
      end

      def defined_filters do
        Enum.reverse(@filters)
      end

      defoverridable [apply_filters: 3, apply_filters: 2, filter_values: 2, filter_values: 1]
    end
  end

  defmacro filter(head = {:when, _, [{name, _, _} | _]}, do: body) do
    define_filter(name, head, body)
  end
  defmacro filter(head = {name, _, _}, do: body) do
    define_filter(name, head, body)
  end

  defp define_filter(filter_name, head, body) do
    quote do
      options = Module.get_attribute(__MODULE__, :options)
      @filters Keyword.put_new(@filters, unquote(filter_name), options || [])
      Module.delete_attribute(__MODULE__, :options)

      def unquote(head), do: unquote(body)
    end
  end
end
