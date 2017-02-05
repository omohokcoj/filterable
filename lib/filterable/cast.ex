defmodule Filterable.Cast do
  def integer(value) when is_bitstring(value) do
    case Integer.parse(value) do
      :error -> nil
      {int, _} -> int
    end
  end
  def integer(value) when is_integer(value) do
    value
  end
  def integer(_) do
    nil
  end

  def string(value) when is_integer(value) do
    Integer.to_string(value)
  end
  def string(value) when is_float(value) do
    Float.to_string(value)
  end
  def string(value) when is_atom(value) do
    Atom.to_string(value)
  end
  def string(value) when is_bitstring(value) do
    value
  end
  def string(_) do
    nil
  end

  def atom(value) when is_bitstring(value) do
    String.to_atom(value)
  end
  def atom(value) when is_atom(value) do
    value
  end
  def atom(_) do
    nil
  end

  def keyword(value) when is_map(value) do
    Map.to_list(value)
  end
  def keyword(value) when is_list(value) do
    if Keyword.keyword?(value) do
      value
    end
  end
  def keyword(_) do
    nil
  end

  def map(value) when is_list(value) do
    if Keyword.keyword?(value) do
      Enum.into(value, %{})
    end
  end
  def map(value) when is_map(value) do
    value
  end
  def map(_) do
    nil
  end

  def date(value) when is_bitstring(value) do
    case Date.from_iso8601(value) do
      {:ok, val} -> val
      {:error, _} -> nil
    end
  end
  def date(%Date{} = value) do
    value
  end
  def date(_) do
    nil
  end

  def datetime(value) when is_bitstring(value) do
    case DateTime.from_iso8601(value) do
      {:ok, val} -> val
      {:error, _} -> nil
    end
  end
  def datetime(%DateTime{} = value) do
    value
  end
  def datetime(_) do
    nil
  end
end
