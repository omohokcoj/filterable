defmodule Filterable.Cast do
  def integer(value) when is_bitstring(value) do
    case Integer.parse(value) do
      :error   -> :error
      {int, _} -> int
    end
  end
  def integer(value) when is_float(value) do
    round(value)
  end
  def integer(value) when is_integer(value) do
    value
  end
  def integer(_) do
    :error
  end

  def float(value) when is_bitstring(value) do
    case Float.parse(value) do
      :error   -> :error
      {int, _} -> int
    end
  end
  def float(value) when is_integer(value) do
    value / 1
  end
  def float(value) when is_float(value) do
    value
  end
  def float(_) do
    :error
  end

  def string(value) when is_bitstring(value) do
    value
  end
  def string(value) do
    Kernel.to_string(value)
  end

  def atom(value) when is_bitstring(value) do
    String.to_atom(value)
  end
  def atom(value) when is_atom(value) do
    value
  end
  def atom(_) do
    :error
  end

  def date(value) when is_bitstring(value) do
    case Date.from_iso8601(value) do
      {:ok, val}  -> val
      {:error, _} -> :error
    end
  end
  def date(%Date{} = value) do
    value
  end
  def date(_) do
    :error
  end

  def datetime(value) when is_bitstring(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, val}  -> val
      {:error, _} -> :error
    end
  end
  def datetime(%NaiveDateTime{} = value) do
    value
  end
  def datetime(_) do
    :error
  end
end
