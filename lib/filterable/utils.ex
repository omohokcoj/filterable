defmodule Filterable.Utils do
  def to_atoms_map(%{__struct__: _} = value), do: value
  def to_atoms_map(value) when is_map(value) or is_list(value) do
    if is_map(value) || (Keyword.keyword?(value) && value != []) do
      Enum.into value, %{}, fn ({k, v}) ->
        {Filterable.Cast.atom(k), to_atoms_map(v)}
      end
    else
      value
    end
  end
  def to_atoms_map(value) do
    value
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
