defmodule Filterable.CastTest do
  use ExUnit.Case
  alias Filterable.Cast

  describe "integer/1" do
    test "returns casted value" do
      assert Cast.integer("123") == 123
      assert Cast.integer(123.123) == 123
    end

    test "returns original value" do
      assert Cast.integer(123) == 123
    end

    test "returns :error if unable to cast" do
      assert Cast.integer("asd") == :error
    end
  end

  describe "float/1" do
    test "returns casted value" do
      assert Cast.float("123.123") == 123.123
      assert Cast.float(123) == 123.0
    end

    test "returns original value" do
      assert Cast.float(123.123) == 123.123
    end

    test "returns :error if unable to cast" do
      assert Cast.float("asd") == :error
    end
  end

  describe "string/1" do
    test "returns casted value" do
      assert Cast.string(123.123) == "123.123"
    end

    test "returns original value" do
      assert Cast.string("test") == "test"
    end
  end

  describe "atom/1" do
    test "returns casted value" do
      assert Cast.atom("string") == :string
    end

    test "returns original value" do
      assert Cast.atom(:atom) == :atom
    end

    test "returns :error if unable to cast" do
      assert Cast.atom(123) == :error
    end
  end

  describe "date/1" do
    test "returns casted value" do
      assert Cast.date("2017-01-01") == ~D[2017-01-01]
    end

    test "returns original value" do
      assert Cast.date(~D[2017-01-01]) == ~D[2017-01-01]
    end

    test "returns :error if unable to cast" do
      assert Cast.date("not a date") == :error
    end
  end

  describe "datetime/1" do
    test "returns casted value" do
      assert Cast.datetime("2017-01-01 00:00:00") == ~N[2017-01-01 00:00:00]
    end

    test "returns original value" do
      assert Cast.datetime(~N[2017-01-01 00:00:00]) == ~N[2017-01-01 00:00:00]
    end

    test "returns :error if unable to cast" do
      assert Cast.datetime("not a date") == :error
    end
  end
end
