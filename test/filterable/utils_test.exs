defmodule Filterable.UtilsTest do
  use ExUnit.Case

  alias Filterable.Utils

  describe "reduce_with/3" do
    test "returns error tuple" do
      assert {:error, "2 not allowed"} =
        Utils.reduce_with([1, 2, 3], [], fn (num, acc) ->
          case num do
            2 -> {:error, "2 not allowed"}
            _ -> acc ++ [num]
          end
        end)
    end

    test "returns ok tuple" do
      assert {:ok, [1, 2, 3]} =
        Utils.reduce_with([1, 2, 3], [], fn (num, acc) ->
          case num do
            4 -> {:error, "4 not allowed"}
            _ -> acc ++ [num]
          end
        end)
    end
  end

  describe "to_atoms_map/1" do
    test "returns map with atom keys" do
      assert Utils.to_atoms_map(%{"page" => %{"per_page" => 3}}) == %{page: %{per_page: 3}}
    end

    test "returns original value if not map" do
      assert Utils.to_atoms_map("page") == "page"
    end

    test "returns struct" do
      assert Utils.to_atoms_map(%{"time" => ~D[2017-01-01]}) == %{time: ~D[2017-01-01]}
    end
  end

  describe "presence/1" do
    test "returns nil if value is empty" do
      assert Utils.presence(%{}) == nil
      assert Utils.presence([]) == nil
      assert Utils.presence('') == nil
      assert Utils.presence("") == nil
      assert Utils.presence(<<>>) == nil
      assert Utils.presence({}) == nil
    end

    test "returns value if not empty" do
      assert Utils.presence("page") == "page"
    end
  end

  describe "ensure_atom/1" do
    test "when value is atom" do
      assert Utils.ensure_atom(:test) == :test
    end

    test "when value is bitsring" do
      assert Utils.ensure_atom("test") == :test
    end

    test "when value is nil" do
      assert Utils.ensure_atom(nil) == nil
    end
  end
end
