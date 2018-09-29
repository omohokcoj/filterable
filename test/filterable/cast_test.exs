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

  describe "boolean/1" do
    test "returns casted value" do
      assert Cast.boolean("true") == true
      assert Cast.boolean("f") == false
    end

    test "returns original value" do
      assert Cast.boolean(true) == true
    end

    test "returns :error if unable to cast" do
      assert Cast.boolean("asd") == :error
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

  describe "atom/2" do
    test "returns the casted string if present in the allowed values" do
      assert Cast.atom("foo", [:foo, :bar]) == :foo
    end

    test "returns :error if the string is not present in the allowed values" do
      assert Cast.atom("toto", [:foo, :bar]) == :error
    end

    test "returns the given atom if it is present in the allowed values" do
      assert Cast.atom(:foo, [:foo, :bar]) == :foo
    end

    test "returns :error if the given atom is not present in the allowed values" do
      assert Cast.atom(:toto, [:foo, :bar]) == :error
    end

    test "returns :error if unable to cast" do
      assert Cast.atom(123, [:foo, :bar]) == :error
    end
  end

  describe "atom_unchecked/1" do
    test "returns casted value" do
      assert Cast.atom_unchecked("string") == :string
    end

    test "returns original value" do
      assert Cast.atom_unchecked(:atom_unchecked) == :atom_unchecked
    end

    test "returns :error if unable to cast" do
      assert Cast.atom_unchecked(123) == :error
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
