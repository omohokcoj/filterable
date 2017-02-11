defmodule FilterableTest do
  use ExUnit.Case
  use Filterable

  alias Filterable.{User, Repo}

  filterable Filterable.UserFilters, share: []

  describe "birthday" do
    test "returns user with birthday" do
      result = User |> apply_filters(birthday: "1968-06-09") |> Repo.all

      assert length(result) == 1
      assert List.first(result).id == 7
      assert List.first(result).birthday == ~D[1968-06-09]
    end

    test "raises errors if date param is invalid" do
      assert_raise Filterable.CastError, "Unable to cast 123 to date", fn ->
        apply_filters(User, birthday: 123)
      end
    end
  end

  describe "position" do
    test "returns user with position" do
      result = User |> apply_filters(position: %{lat: 34, lng: -80}) |> Repo.all

      assert length(result) == 1
      assert List.first(result).id == 9
      assert List.first(result).latlng == [34.188195, -80.278694]
    end

    test "returns all users if position not set" do
      result = User |> apply_filters(position: %{}) |> Repo.all

      assert length(result) == 4
      assert List.first(result).id == 1
    end
  end

  describe "sort" do
    test "returns users sorted by name asc" do
      result = User |> apply_filters(sort: %{field: "name", order: "asc"}) |> Repo.all

      assert length(result) == 4
      assert List.first(result).id == 8
      assert List.first(result).name == "Barry"
    end

    test "returns users sorted by surname" do
      result = User |> apply_filters(sort: %{field: "surname"}) |> Repo.all

      assert length(result) == 4
      assert List.first(result).id == 6
      assert List.first(result).surname == "Valentine"
    end

    test "raises error if sort direction invalid" do
      assert_raise Filterable.InvalidParamError, "Unable to sort using :test, only 'asc' and 'desc' allowed", fn ->
        apply_filters(User, sort: %{field: :name, order: :test})
      end
    end

    test "raises error if sort field invalid" do
      assert_raise Filterable.InvalidParamError, "Unable to sort on :test, only name and surname allowed", fn ->
        apply_filters(User, sort: %{field: :test, order: :desc})
      end
    end
  end

  describe "paginate" do
    test "with defaults" do
      result = User |> apply_filters(%{}) |> Repo.all
      assert List.first(result).id == 1
      assert List.last(result).id == 4
    end

    test "with single record per page" do
      result = User |> apply_filters(per_page: 1) |> Repo.all
      assert List.first(result).id == 1
      assert List.last(result).id == 1
    end

    test "with second page" do
      result = User |> apply_filters(page: 2) |> Repo.all
      assert List.first(result).id == 5
      assert List.last(result).id == 8
    end

    test "raises error with very large per_page" do
      assert_raise Filterable.InvalidParamError, "Per page can't more than 5", fn ->
        apply_filters(User, per_page: 100)
      end
    end

    test "raises error with negative page" do
      assert_raise Filterable.InvalidParamError, "Page can't be negative", fn ->
        apply_filters(User, page: -100)
      end
    end

    test "raises error with negative per_page" do
      assert_raise Filterable.InvalidParamError, "Per page can't be negative", fn ->
        apply_filters(User, per_page: -100)
      end
    end
  end
end
