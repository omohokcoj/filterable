defmodule Filterable.Phoenix.Model do
  defmacro __using__(_) do
    quote do
      use Filterable

      @before_compile unquote(__MODULE__)
      @filters_module __MODULE__
      @filter_options []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def apply_filters!(%Plug.Conn{params: params} = conn, opts \\ []) do
        Filterable.apply_filters!(__MODULE__, params, @filters_module, filter_options(conn, opts))
      end

      def apply_filters(%Plug.Conn{params: params} = conn, opts \\ []) do
        Filterable.apply_filters(__MODULE__, params, @filters_module, filter_options(conn, opts))
      end

      def filter_values(%Plug.Conn{params: params} = conn, opts \\ []) do
        Filterable.filter_values(params, @filters_module, filter_options(conn, opts))
      end

      def filter_options(conn, opts \\ []) do
        [share: conn] |> Keyword.merge(opts) |> Keyword.merge(@filter_options)
      end
    end
  end
end
