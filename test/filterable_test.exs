defmodule FilterableTest do
  use ExUnit.Case
  use Filterable

  filterable Filterable.UserListFilters

  @users [%{name: "Tom", age: 22},
          %{name: "Jony", age: 23}]

  test "filters using module function" do
    result = Filterable.apply_filters(@users, [name: "Tom", age: 21], Filterable.UserListFilters)
    assert result == []

    result = Filterable.apply_filters(@users, [age: 22], Filterable.UserListFilters)
    assert result == [List.first(@users)]
  end

  test "filters using macro" do
    result = apply_filters(@users, name: "Tom", age: 21)
    assert result == []

    result = apply_filters(@users, age: "22")
    assert result == [%{name: "Tom", age: 22}]

    result = apply_filters(@users, age: 190)
    assert result == @users
  end

  test "returns filter values" do
    result = filter_values(name: "Tom", age: 21, about: nil, another: "test")
    assert result == [name: "Tom", age: 21]
  end
end
