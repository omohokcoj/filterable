defmodule Filterable.Phoenix.ModelTest do
  use ExUnit.Case

  alias Filterable.{User, Repo}

  test "filters using module function" do
    params = Plug.Conn.Query.decode("name=Martin&age=22")
    query  = Filterable.apply_filters(User, params, Filterable.UserFilters, share: [])
    assert Repo.one(query).name == "Martin"

    params = Plug.Conn.Query.decode("name=    &age=190")
    query  = Filterable.apply_filters(User, params, Filterable.UserFilters, share: [])
    assert length(Repo.all(query)) == 4
  end

  test "filters using macro" do
    params = Plug.Conn.Query.decode("name=Martin")
    query  = User.apply_filters(%Plug.Conn{params: params})
    assert Repo.one(query).name == "Martin"

    params = Plug.Conn.Query.decode("name=   &age=190")
    query  = User.apply_filters(%Plug.Conn{params: params})
    assert length(Repo.all(query)) == 10
  end

  test "returns filter values" do
    params = Plug.Conn.Query.decode("name=Tom&age=21&about=''&another='test'")
    result = User.filter_values(%Plug.Conn{params: params})
    assert result == %{name: "Tom", age: 21}
  end
end
