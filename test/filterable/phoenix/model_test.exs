defmodule Filterable.Phoenix.ModelTest do
  use ExUnit.Case

  alias Filterable.{User, Repo}

  test "filters using module function" do
    params = Plug.Conn.Query.decode("name=Martin&age=22")

    {:ok, query, values} =
      Filterable.apply_filters(User, params, Filterable.UserFilters, share: [])

    assert Repo.one(query).name == "Martin"

    assert values == %{
             name: "Martin",
             age: 22,
             paginate: %{page: 1, per_page: 4},
             sort: %{order: "desc", sort: nil}
           }

    params = Plug.Conn.Query.decode("name=    &age=190")

    {:ok, query, values} =
      Filterable.apply_filters(User, params, Filterable.UserFilters, share: [])

    assert length(Repo.all(query)) == 4

    assert values == %{
             age: 190,
             paginate: %{page: 1, per_page: 4},
             sort: %{order: "desc", sort: nil}
           }
  end

  test "filters using macro" do
    params = Plug.Conn.Query.decode("name=Martin")
    {:ok, query, values} = User.apply_filters(%Plug.Conn{params: params})
    assert Repo.one(query).name == "Martin"
    assert values == %{name: "Martin", limit: 20, offset: 0}

    params = Plug.Conn.Query.decode("name=   &age=190")
    {:ok, query, values} = User.apply_filters(%Plug.Conn{params: params})
    assert length(Repo.all(query)) == 10
    assert values == %{age: 190, limit: 20, offset: 0}
  end

  test "returns filter values" do
    params = Plug.Conn.Query.decode("name=Tom&age=21&about=''&another='test'")
    {:ok, result} = User.filter_values(%Plug.Conn{params: params})
    assert result == %{name: "Tom", age: 21, limit: 20, offset: 0}
  end
end
