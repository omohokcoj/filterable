defmodule Filterable.Params do
  alias Filterable.Utils

  @available_options [:top_param, :param, :trim, :allow_blank, :default, :cast]

  def filter_value(params, opts \\ []) do
    [
      top_param_key,
      param_key,
      trim_opt,
      allow_blank_opt,
      default_opt,
      cast_opt
    ] = fetch_options(opts)

    params
    |> Utils.to_atoms_map
    |> fetch_params(top_param_key)
    |> fetch_value(param_key)
    |> normalize_map
    |> trim_value(trim_opt)
    |> cast_value(cast_opt)
    |> nilify_value(allow_blank_opt)
    |> default_value(default_opt)
  end

  defp fetch_options(opts) do
    Enum.map(@available_options, &Keyword.get(opts, &1))
  end

  defp fetch_params(params, nil) do
    params
  end
  defp fetch_params(params, key) do
    Utils.get_indifferent(params, key)
  end

  defp fetch_value(nil, _) do
    nil
  end
  defp fetch_value(params, key) when is_list(key) do
    if Keyword.keyword?(key) do
      Enum.reduce key, %{}, fn ({k, v}, acc) ->
        Map.put(acc, k, fetch_value(fetch_value(params, k), v))
      end
    else
      Enum.into(key, %{}, &{&1, fetch_value(params, &1)})
    end
  end
  defp fetch_value(params, key) when is_map(params) do
    Utils.get_indifferent(params, key)
  end
  defp fetch_value(_, _) do
    nil
  end

  defp normalize_map(map) when map_size(map) == 1 do
    map |> Map.values |> List.first
  end
  defp normalize_map(map) do
    map
  end

  defp trim_value(value, true) do
    trim_value(value)
  end
  defp trim_value(value, _) do
    value
  end
  defp trim_value(%{__struct__: _} = value) do
    value
  end
  defp trim_value(value) when is_bitstring(value) do
    String.trim(value)
  end
  defp trim_value(value) when is_list(value) do
    Enum.map(value, &trim_value(&1))
  end
  defp trim_value(value) when is_map(value) do
    Enum.into(value, %{}, fn ({k, v}) -> {k, trim_value(v)} end)
  end
  defp trim_value(value) do
    value
  end

  defp nilify_value(value, allow_blank) when allow_blank in [nil, false] do
    nilify_value(value)
  end
  defp nilify_value(value, _) do
    value
  end
  defp nilify_value(%{__struct__: _} = value) do
    value
  end
  defp nilify_value(value) when is_bitstring(value) do
    Utils.presence(value)
  end
  defp nilify_value(value) when is_list(value) do
    value |> Enum.filter(&nilify_value(&1)) |> Utils.presence
  end
  defp nilify_value(value) when is_map(value) do
    value |> Enum.into(%{}, fn ({k, v}) -> {k, nilify_value(v)} end) |> Utils.presence
  end
  defp nilify_value(value) do
    value
  end

  defp default_value(%{__struct__: _} = value, _) do
    value
  end
  defp default_value(value, default) when is_map(value) and is_list(default) do
    Enum.into value, %{}, fn ({k, v}) ->
      {k, default_value(v, Keyword.get(default, k))}
    end
  end
  defp default_value(value, default) when not is_map(value) and is_list(default) do
    if Keyword.keyword?(default) do
      value
    else
      value || default
    end
  end
  defp default_value(nil, default) do
    default
  end
  defp default_value(value, _) do
    value
  end

  defp cast_value(value, nil) do
    value
  end
  defp cast_value(%{__struct__: _} = value, cast) do
    apply(Filterable.Cast, cast, [value])
  end
  defp cast_value(value, cast) when is_map(value) do
    Enum.into(value, %{}, fn ({k, v}) -> {k, cast_value(v, cast)} end)
  end
  defp cast_value(value, cast) when is_list(value) do
    value |> Enum.map(&cast_value(&1, cast)) |> Enum.reject(&is_nil/1)
  end
  defp cast_value(value, cast) when is_list(cast) do
    Enum.reduce(cast, value, &(&1.(&2)))
  end
  defp cast_value(value, cast) when is_function(cast) do
    cast.(value)
  end
  defp cast_value(value, cast) when is_atom(cast) do
    apply(Filterable.Cast, cast, [value])
  end
  defp cast_value(value, _) do
    value
  end
end
