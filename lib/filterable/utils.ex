defmodule Filterable.Utils do
  def ensure_atoms_map([]), do: []
  def ensure_atoms_map(%{__struct__: _} = value), do: value
  def ensure_atoms_map(value) do
    if is_map(value) || Keyword.keyword?(value) do
      Enum.into value, %{}, fn ({k, v}) ->
        {if(is_bitstring(k), do: String.to_atom(k), else: k), ensure_atoms_map(v)}
      end
    else
      value
    end
  end

  def presence(value) when value in ["", [], {}, %{}] do
    nil
  end
  def presence(value) do
    value
  end

  def get_indifferent(collection, key, default \\ nil)
  def get_indifferent(collection, key, default) when is_nil(key) or is_nil(collection) do
    default
  end
  def get_indifferent(collection, key, default) when is_map(collection) and is_bitstring(key) do
    Map.get(collection, key) || Map.get(collection, String.to_atom(key), default)
  end
  def get_indifferent(collection, key, default) when is_map(collection) and is_atom(key) do
    Map.get(collection, key) || Map.get(collection, Atom.to_string(key), default)
  end
  def get_indifferent(collection, key, default) when is_list(collection) and is_bitstring(key) do
    Keyword.get(collection, String.to_atom(key), default)
  end
  def get_indifferent(collection, key, default) when is_list(collection) and is_atom(key) do
    Keyword.get(collection, key, default)
  end
end
