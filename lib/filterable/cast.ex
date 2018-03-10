defmodule Filterable.Cast do
  @moduledoc ~S"""
  Contains functions which perform filter values type casting.
  Each function should return casted value or `:error` atom.
  """

  @spec integer(String.t() | number) :: integer | :error
  def integer(value) when is_bitstring(value) do
    case Integer.parse(value) do
      :error -> :error
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

  @spec float(String.t() | number) :: float | :error
  def float(value) when is_bitstring(value) do
    case Float.parse(value) do
      :error -> :error
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

  @spec boolean(String.t() | boolean) :: boolean | :error
  def boolean(value) when is_bitstring(value) do
    cond do
      value in ["true", "t"] -> true
      value in ["false", "f"] -> false
      true -> :error
    end
  end

  def boolean(value) when is_boolean(value) do
    value
  end

  def boolean(_) do
    :error
  end

  @spec string(any) :: String.t()
  def string(value) when is_bitstring(value) do
    value
  end

  def string(value) do
    to_string(value)
  end

  @spec atom(String.t() | atom) :: atom | :error
  def atom(value) when is_bitstring(value) do
    String.to_atom(value)
  end

  def atom(value) when is_atom(value) do
    value
  end

  def atom(_) do
    :error
  end

  @spec date(String.t() | Date.t()) :: Date.t() | :error
  def date(value) when is_bitstring(value) do
    case Date.from_iso8601(value) do
      {:ok, val} -> val
      {:error, _} -> :error
    end
  end

  def date(%Date{} = value) do
    value
  end

  def date(_) do
    :error
  end

  @spec datetime(String.t() | NaiveDateTime.t()) :: NaiveDateTime.t() | :error
  def datetime(value) when is_bitstring(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, val} -> val
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
