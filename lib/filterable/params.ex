defmodule Filterable.Params do
  alias Filterable.Utils

  @available_options [:params, :param, :trim, :allow_blank, :default, :cast]

  def filter_value(params, opts \\ []) do
    [params_key, param_key, trim_opt,
     allow_blank_opt, default_opt, cast_opt] = fetch_options(opts)

    params
    |> fetch_params(params_key)
    |> fetch_value(param_key)
    |> trim_value(trim_opt)
    |> nilify_value(allow_blank_opt)
    |> default_value(default_opt)
    |> cast_value(cast_opt)
  end

  defp fetch_options(options) do
    Enum.map(@available_options, fn (key) -> Keyword.get(options, key) end)
  end

  defp fetch_params(params, key) do
    Utils.get_indifferent(params, key) || params
  end

  defp fetch_value(params, key) do
    Utils.get_indifferent(params, key)
  end

  defp trim_value(value, true) when is_bitstring(value), do: String.trim(value)
  defp trim_value(value, _), do: value

  defp nilify_value(value, allow_blank) when allow_blank in [nil, false] do
    case value in ["", [], {}, %{}] do
      true -> nil
      false -> value
    end
  end
  defp nilify_value(value, _), do: value

  defp default_value(value, default_value) when is_nil(value), do: default_value
  defp default_value(value, _), do: value

  defp cast_value(value, cast) when is_function(cast), do: cast.(value)
  defp cast_value(value, cast) when is_list(cast) do
    Enum.reduce(cast, value, fn (cast_fn, value) -> cast_fn.(value) end)
  end
  defp cast_value(value, _), do: value
end
