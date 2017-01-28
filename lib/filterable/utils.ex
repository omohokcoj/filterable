defmodule Filterable.Utils do
  def presence(value) when value in ["", [], {}, %{}],
    do: nil
  def presence(value),
    do: value

  def get_indifferent(collection, key, default \\ nil)
  def get_indifferent(map, key, default) when is_map(map),
    do: Map.get(map, key, default) || Map.get(map, swap_key_type(key), default)
  def get_indifferent(list, key, default) when is_list(list),
    do: Keyword.get(list, key, default)

  defp swap_key_type(key) when is_bitstring(key),
    do: String.to_atom(key)
  defp swap_key_type(key) when is_atom(key) and not is_nil(key),
    do: Atom.to_string(key)
end
