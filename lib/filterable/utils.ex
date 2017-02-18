defmodule Filterable.Utils do
  def to_atoms_map([]), do: []
  def to_atoms_map(%{__struct__: _} = value), do: value
  def to_atoms_map(value) do
    if is_map(value) || Keyword.keyword?(value) do
      Enum.into value, %{}, fn ({k, v}) ->
        {if(is_bitstring(k), do: String.to_atom(k), else: k), to_atoms_map(v)}
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

  def get_indifferent(map, key, default \\ nil)
  def get_indifferent(map, key, default) when is_nil(key) or is_nil(map) do
    default
  end
  def get_indifferent(map, key, default) when is_bitstring(key) do
    Map.get(map, key) || Map.get(map, String.to_atom(key), default)
  end
  def get_indifferent(map, key, default) when is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key), default)
  end
end
