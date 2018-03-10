defmodule FilterableTest do
  use ExUnit.Case
  use Filterable

  alias Filterable.{User, Repo}

  filterable(Filterable.UserFilters, share: %{})

  describe "birthday" do
    test "returns user with birthday" do
      {:ok, query, _} = apply_filters(User, birthday: "1968-06-09")
      result = Repo.all(query)

      assert length(result) == 1
      assert List.first(result).id == 7
      assert List.first(result).birthday == ~D[1968-06-09]
    end

    test "return error tuple if date param is invalid" do
      assert {:error, "Unable to cast 123 to date"} = apply_filters(User, birthday: 123)
    end
  end

  describe "position" do
    test "returns user with position" do
      {:ok, query, _} = apply_filters(User, position: %{lat: 34, lng: -80})
      result = Repo.all(query)

      assert length(result) == 1
      assert List.first(result).id == 9
      assert List.first(result).latlng == [34.188195, -80.278694]
    end

    test "returns all users if position not set" do
      {:ok, query, _} = apply_filters(User, position: %{})
      result = Repo.all(query)

      assert length(result) == 4
      assert List.first(result).id == 1
    end
  end

  describe "sort" do
    test "returns users sorted by name asc" do
      {:ok, query, _} = apply_filters(User, %{sort: "name", order: "asc"})
      result = Repo.all(query)

      assert length(result) == 4
      assert List.first(result).id == 8
      assert List.first(result).name == "Barry"
    end

    test "returns users sorted by surname" do
      {:ok, query, _} = apply_filters(User, %{sort: "surname"})
      result = Repo.all(query)

      assert length(result) == 4
      assert List.first(result).id == 6
      assert List.first(result).surname == "Valentine"
    end

    test "returns error if sort direction invalid" do
      {:error, message} = apply_filters(User, %{sort: :name, order: :test})
      assert message == "Unable to sort using :test, only 'asc' and 'desc' allowed"
    end

    test "raises error if sort field invalid" do
      {:error, message} = apply_filters(User, %{sort: :test, order: :desc})
      assert message == "Unable to sort on :test, only name and surname allowed"
    end
  end

  describe "paginate" do
    test "returns result using default params" do
      {query, _} = apply_filters!(User, %{})
      result = Repo.all(query)

      assert List.first(result).id == 1
      assert List.last(result).id == 4
    end

    test "returns single record per page" do
      {query, _} = apply_filters!(User, per_page: 1)
      result = Repo.all(query)

      assert List.first(result).id == 1
      assert List.last(result).id == 1
    end

    test "returns second page" do
      {query, _} = apply_filters!(User, page: 2)
      result = Repo.all(query)

      assert List.first(result).id == 5
      assert List.last(result).id == 8
    end

    test "raises error if very large per_page" do
      assert_raise Filterable.FilterError, "per_page can't be more than 4", fn ->
        apply_filters!(User, per_page: 100)
      end
    end

    test "returns error tuple if negative page" do
      assert_raise Filterable.FilterError, "page can't be negative", fn ->
        apply_filters!(User, page: -100)
      end
    end

    test "returns error tuple if negative per_page" do
      assert_raise Filterable.FilterError, "per_page can't be negative", fn ->
        apply_filters!(User, per_page: -100)
      end
    end
  end

  describe "limit offset" do
    test "returns result using default params" do
      {query, _} = User.apply_filters!(%Plug.Conn{params: %{}})
      result = Repo.all(query)

      assert List.first(result).id == 1
      assert List.last(result).id == 10
    end

    test "returns single record" do
      {query, _} = User.apply_filters!(%Plug.Conn{params: %{"limit" => 1}})
      result = Repo.all(query)

      assert List.first(result).id == 1
      assert List.last(result).id == 1
    end

    test "returns second record" do
      {query, _} = User.apply_filters!(%Plug.Conn{params: %{limit: 1, offset: 1}})
      result = Repo.all(query)

      assert List.first(result).id == 2
      assert List.last(result).id == 2
    end

    test "raises error if very large limit" do
      assert_raise Filterable.FilterError, "limit can't be more than 20", fn ->
        User.apply_filters!(%Plug.Conn{params: %{limit: 2000, offset: 1}})
      end
    end

    test "returns error tuple if negative limit" do
      assert_raise Filterable.FilterError, "limit can't be negative", fn ->
        User.apply_filters!(%Plug.Conn{params: %{limit: -2000, offset: 1}})
      end
    end

    test "returns error tuple if negative offset" do
      assert_raise Filterable.FilterError, "offset can't be negative", fn ->
        User.apply_filters!(%Plug.Conn{params: %{limit: 1, offset: -1}})
      end
    end
  end
end
