defmodule Filterable.Params do
  @moduledoc ~S"""
  Allows to fetch `Map` of filterable params.
  Performs casting/triming/normalization of filter params.
  """

  alias Filterable.Utils

  @spec filter_value(map | Keyword.t(), Keyword.t()) :: {:ok | :error, any}
  def filter_value(params, opts \\ []) do
    with params <- fetch_params(params, Keyword.get(opts, :top_param)),
         value <- fetch_value(params, Keyword.get(opts, :param)),
         value <- Utils.to_atoms_map(value),
         value <- normalize_map(value),
         value <- trim_value(value, Keyword.get(opts, :trim)),
         value <- nilify_value(value, Keyword.get(opts, :allow_blank)),
         {:ok, value} <-
           cast_value(value, Keyword.get(opts, :cast), Keyword.get(opts, :cast_errors)),
         value <- default_value(value, Keyword.get(opts, :default)),
         do: {:ok, value}
  end

  defp fetch_params(params, key) do
    if key do
      fetch_value(params, key)
    else
      params
    end
  end

  defp fetch_value(nil, _) do
    nil
  end

  defp fetch_value(params, key) when is_list(key) do
    if Keyword.keyword?(key) do
      Enum.into(key, %{}, fn {k, v} ->
        {k, fetch_value(fetch_value(params, k), v)}
      end)
    else
      Enum.into(key, %{}, &{&1, fetch_value(params, &1)})
    end
  end

  defp fetch_value(params, key) when is_map(params) do
    Map.get(params, Utils.ensure_string(key)) || Map.get(params, Utils.ensure_atom(key))
  end

  defp fetch_value(params, key) when is_list(params) do
    if Keyword.keyword?(params) do
      Keyword.get(params, key)
    end
  end

  defp fetch_value(_, _) do
    nil
  end

  defp normalize_map(map) when map_size(map) == 1 do
    map |> Map.values() |> List.first()
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
    Enum.into(value, %{}, fn {k, v} -> {k, trim_value(v)} end)
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
    value |> Enum.filter(&nilify_value(&1)) |> Utils.presence()
  end

  defp nilify_value(value) when is_map(value) do
    value |> Enum.into(%{}, fn {k, v} -> {k, nilify_value(v)} end) |> Utils.presence()
  end

  defp nilify_value(value) do
    value
  end

  defp default_value(%{__struct__: _} = value, _) do
    value
  end

  defp default_value(value, default) when is_map(value) and is_list(default) do
    Enum.into(value, %{}, fn {k, v} ->
      {k, default_value(v, Keyword.get(default, k))}
    end)
  end

  defp default_value(value, default) when not is_map(value) and is_list(default) do
    if Keyword.keyword?(default) do
      value
    else
      (is_nil(value) && default) || value
    end
  end

  defp default_value(nil, default) do
    default
  end

  defp default_value(value, _) do
    value
  end

  defp cast_value(value, nil, _) do
    {:ok, value}
  end

  defp cast_value(%{__struct__: _} = value, cast, errors) do
    cast(value, cast, errors)
  end

  defp cast_value(value, cast, errors) when is_map(value) do
    Utils.reduce_with(value, %{}, fn {k, v}, acc ->
      case cast(v, cast, errors) do
        error = {:error, _} -> error
        {:ok, val} -> Map.put(acc, k, val)
      end
    end)
  end

  defp cast_value(value, cast, errors) when is_list(value) do
    Utils.reduce_with(value, [], fn val, acc ->
      case cast(val, cast, errors) do
        error = {:error, _} -> error
        {:ok, nil} -> acc
        {:ok, val} -> acc ++ [val]
      end
    end)
  end

  defp cast_value(value, cast, errors) do
    cast(value, cast, errors)
  end

  defp cast(value, cast, errors) when is_list(cast) do
    Utils.reduce_with(cast, value, fn c, val ->
      case cast(val, c, errors) do
        error = {:error, _} -> error
        {:ok, val} -> val
      end
    end)
  end

  defp cast(value, cast, true) do
    case cast(value, cast) do
      :error -> {:error, cast_error_message(value: value, cast: cast)}
      error = {:error, _} -> error
      value -> {:ok, value}
    end
  end

  defp cast(value, cast, _) do
    case cast(value, cast) do
      :error -> {:ok, nil}
      {:error, _} -> {:ok, nil}
      value -> {:ok, value}
    end
  end

  defp cast(nil, _) do
    nil
  end

  defp cast(value, :atom) do
    cast(value, :atom_unchecked)
  end

  defp cast(value, {:atom, checked_values}) do
    Filterable.Cast.atom(value, checked_values)
  end

  defp cast(value, cast) when is_atom(cast) do
    apply(Filterable.Cast, cast, [value])
  end

  defp cast(value, cast) when is_function(cast) do
    cast.(value)
  end

  defp cast(value, _) do
    value
  end

  defp cast_error_message(value: value, cast: {cast, params}) when is_atom(cast) do
    "Unable to cast #{inspect(value)} to #{to_string(cast)} with options: #{inspect(params)}"
  end

  defp cast_error_message(value: value, cast: cast) when is_function(cast) do
    "Unable to cast #{inspect(value)} using #{inspect(cast)}"
  end

  defp cast_error_message(value: value, cast: cast) when is_atom(cast) do
    "Unable to cast #{inspect(value)} to #{to_string(cast)}"
  end
end
