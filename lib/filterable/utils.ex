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

  def ensure_atom(value) when is_bitstring(value), do: String.to_atom(value)
  def ensure_atom(value) when is_atom(value), do: value

  def presence(value) when value in ["", [], {}, %{}], do: nil
  def presence(value), do: value
end
