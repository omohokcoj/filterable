defmodule Filterable.UtilsTest do
  use ExUnit.Case, async: true

  alias Filterable.Utils

  describe "to_atoms_map/1" do
    test "returns map with atom keys" do
      assert Utils.to_atoms_map(%{"page" => %{"per_page" => 3}}) == %{page: %{per_page: 3}}
    end

    test "returns original value if not map" do
      assert Utils.to_atoms_map("page") == "page"
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

  describe "get_indifferent/2" do
    test "returns from map using string key" do
      assert Utils.get_indifferent(%{page: "test"}, "page") == "test"
    end

    test "returns from map using atom key" do
      assert Utils.get_indifferent(%{"page" => "test"}, :page) == "test"
    end

    test "returns from keyword list using string key" do
      assert Utils.get_indifferent([page: "test"], "page") == "test"
    end

    test "returns from keyword list using atom key" do
      assert Utils.get_indifferent([page: "test"], :page) == "test"
    end

    test "returns nil if value not found" do
      assert Utils.get_indifferent([page: "test"], "bad_key") == nil
    end
  end

  describe "get_indifferent/3" do
    test "returns default value" do
      assert Utils.get_indifferent(%{page: "test"}, nil, "default") == "default"
    end
  end
end
