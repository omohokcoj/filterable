defmodule Filterable.Cast do
  def integer(value) when is_bitstring(value) do
    case Integer.parse(value) do
      :error -> nil
      {int, _} -> int
    end
  end
  def integer(value) do
    value
  end

  def atom(value) when is_bitstring(value) do
    String.to_atom(value)
  end
  def atom(value) do
    value
  end

  def date(value) when is_bitstring(value) do
    case Date.from_iso8601(value) do
      {:ok, val} -> val
      {:error, _} -> nil
    end
  end
  def date(value) do
    value
  end

  def datetime(value) when is_bitstring(value) do
    case DateTime.from_iso8601(value) do
      {:ok, val} -> val
      {:error, _} -> nil
    end
  end
  def datetime(value) do
    value
  end
end
