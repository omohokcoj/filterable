defmodule Filterable.Utils do
  @spec reduce_with(Enum.t, any, (Enum.element, any -> {:cont, {:ok, any}} | {:halt, any})) :: any
  def reduce_with(enumerable, acc, fun) do
    Enum.reduce_while enumerable, {:ok, acc}, fn (val, {:ok, acc}) ->
      case fun.(val, acc) do
        error = {:error, _} -> {:halt, error}
        value = {:ok, _}    -> {:cont, value}
        value               -> {:cont, {:ok, value}}
      end
    end
  end

  @spec to_atoms_map(list | map) :: map
  def to_atoms_map([]), do: []
  def to_atoms_map(%{__struct__: _} = value), do: value
  def to_atoms_map(value) do
    if is_map(value) || Keyword.keyword?(value) do
      Enum.into value, %{}, fn ({k, v}) ->
        {ensure_atom(k), to_atoms_map(v)}
      end
    else
      value
    end
  end

  def presence(value) when value in ["", [], {}, %{}], do: nil
  def presence(value), do: value

  @spec ensure_atom(String.t | atom) :: atom
  def ensure_atom(value) when is_bitstring(value), do: String.to_atom(value)
  def ensure_atom(value) when is_atom(value), do: value
end
