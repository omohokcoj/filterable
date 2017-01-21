defmodule Filterable.Utils do
  def get_indifferent(map, key) when is_map(map) do
    Map.get(map, key) || Map.get(map, swap_key_type(key))
  end
  def get_indifferent(list, key) when is_list(list) do
    Keyword.get(list, key)
  end

  defp swap_key_type(key) when is_bitstring(key), do: String.to_atom(key)
  defp swap_key_type(key) when is_atom(key) and not is_nil(key), do: Atom.to_string(key)
  defp swap_key_type(key), do: key
end
