defmodule Filterable.Phoenix.ControllerTest do
  use ExUnit.Case
  use Filterable.Phoenix.Controller

  import Ecto.Query

  alias Filterable.{User, Repo}

  filterable do
    filter name(query, value, _conn) do
      query |> where(name: ^value)
    end

    @options cast: :integer
    filter age(query, value, _conn) when value < 120 do
      query |> where(age: ^value)
    end
  end

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
    query  = apply_filters(User, %Plug.Conn{params: params})
    assert Repo.one(query).name == "Martin"

    params = Plug.Conn.Query.decode("name=   &age=190")
    query  = apply_filters(User, %Plug.Conn{params: params})
    assert length(Repo.all(query)) == 10
  end

  test "returns filter values" do
    params = Plug.Conn.Query.decode("name=Tom&age=21&about=''&another='test'")
    result = filter_values(%Plug.Conn{params: params})
    assert result == %{name: "Tom", age: 21}
  end
end
