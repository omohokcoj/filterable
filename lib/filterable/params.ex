defmodule Filterable.Params do
  alias Filterable.Utils

  @available_options [:params, :param, :trim, :allow_blank, :default, :cast]

  def filter_value(params, opts \\ []) do
    [params_key, param_key, trim_opt, allow_blank_opt, default_opt, cast_opt] = fetch_options(opts)

    params
    |> fetch_params(params_key)
    |> fetch_value(param_key)
    |> trim_value(trim_opt)
    |> nilify_value(allow_blank_opt)
    |> default_value(default_opt)
    |> cast_value(cast_opt)
  end

  defp fetch_options(opts) do
    Enum.map(@available_options, &Keyword.get(opts, &1))
  end

  defp fetch_params(params, key) do
    Utils.get_indifferent(params, key, params)
  end

  defp fetch_value(params, key) when is_list(key) do
    Enum.reduce key, %{}, fn (k, acc) ->
      Map.put(acc, k, Utils.get_indifferent(params, k))
    end
  end
  defp fetch_value(params, key) do
    Utils.get_indifferent(params, key)
  end

  defp trim_value(value, opt) when opt == true do
    trim_value(value)
  end
  defp trim_value(value, _) do
    value
  end
  defp trim_value(value) when is_bitstring(value) do
    String.trim(value)
  end
  defp trim_value(value) when is_list(value) do
    if Keyword.keyword?(value) do
      Enum.map(value, fn ({k, v}) -> {k, trim_value(v)} end)
    else
      Enum.map(value, &trim_value(&1))
    end
  end
  defp trim_value(value) when is_map(value) do
    Enum.reduce value, %{}, fn ({k, v}, acc) ->
      Map.put(acc, k, trim_value(v))
    end
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
  defp nilify_value(value) when is_bitstring(value) do
    Utils.presence(value)
  end
  defp nilify_value(value) when is_list(value) do
    if Keyword.keyword?(value) do
      Enum.filter(value, fn ({_, v}) -> nilify_value(v) end)
    else
      Enum.filter(value, &nilify_value(&1))
    end
    |> Utils.presence
  end
  defp nilify_value(value) when is_map(value) do
    value
    |> Enum.filter(fn ({_, v}) -> nilify_value(v) end)
    |> Enum.into(%{})
    |> Utils.presence
  end
  defp nilify_value(value) do
    value
  end

  defp default_value(value, default_value) when is_list(value) and is_list(default_value) do
    if Keyword.keyword?(value) && Keyword.keyword?(default_value) do
      Keyword.merge(default_value, value)
    else
      value
    end
  end
  defp default_value(value, default_value) when is_map(value) and is_list(default_value) do
    if Keyword.keyword?(default_value) do
      default_value |> Enum.into(%{}) |> Map.merge(value)
    else
      value
    end
  end
  defp default_value(value, default_value) when is_map(value) and is_map(default_value) do
    Map.merge(default_value, value)
  end
  defp default_value(value, default_value) when is_nil(value) do
    default_value
  end
  defp default_value(value, _) do
    value
  end

  defp cast_value(value, cast) when is_list(value) do
    if Keyword.keyword?(value) do
      Enum.reduce value, [], fn ({k, v}, acc) ->
        Keyword.put(acc, k, cast_value(v, cast))
      end
    else
      Enum.map(value, &cast_value(&1, cast))
    end
  end
  defp cast_value(value, cast) when is_map(value) do
    Enum.reduce value, %{}, fn ({k, v}, acc) ->
      Map.put(acc, k, cast_value(v, cast))
    end
  end
  defp cast_value(value, cast) when is_list(cast) do
    Enum.reduce(cast, value, &(&1.(&2)))
  end
  defp cast_value(value, cast) when is_function(cast) do
    cast.(value)
  end
  defp cast_value(value, _) do
    value
  end
end
