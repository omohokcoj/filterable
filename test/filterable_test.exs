defmodule FilterableTest do
  use ExUnit.Case

  import Filterable.ParamFilters, only: [apply_filters: 2]

  setup_all do
    {:ok, %{name: "Tom", bio: "  was born", age: 23, friends: ["Jonny"],
            enemies: [], skills: %{"vox" => 1}, address: " "}}
  end

  test "returns filter value", params do
    value = apply_filters(params, param: :name)
    assert value == "Tom"

    value = apply_filters(params, param: :age)
    assert value == 23

    value = apply_filters(params, param: :friends)
    assert value == ["Jonny"]
  end

  test "returns filter value with indifferent access", params do
    value = apply_filters(params, param: "name")
    assert value == "Tom"
  end

  test "returns trimed value", params do
    value = apply_filters(params, param: :bio, trim: true)
    assert value == "was born"

    value = apply_filters(params, param: :skills, trim: true)
    assert value == %{"vox" => 1}
  end

  test "returns nilifed value", params do
    value = apply_filters(params, param: :enemies)
    assert value == nil

    value = apply_filters(params, param: :address)
    assert value == nil
  end

  test "returns blank value", params do
    value = apply_filters(params, param: :enemies, allow_blank: true, trim: true)
    assert value == []

    value = apply_filters(params, param: :address, allow_blank: true, trim: true)
    assert value == ""
  end

  test "returns default value", params do
    value = apply_filters(params, param: :enemies, default: "cool")
    assert value == "cool"

    value = apply_filters(params, param: :address, default: "cool", trim: true)
    assert value == "cool"
  end

  test "doesn't return default value when value present", params do
    value = apply_filters(params, param: :name, default: "cool")
    assert value == "Tom"

    value = apply_filters(params, param: :address, default: "cool", trim: false)
    assert value == " "
  end

  test "returns casted value", params do
    value = apply_filters(params, param: :name, cast: &String.downcase/1)
    assert value == "tom"

    value = apply_filters(params, param: :name, cast: [&String.downcase/1, &String.to_atom/1])
    assert value == :tom
  end

  test "returns shared value", params do
    value = apply_filters(params, param: :name, share: true)
    assert value == "shared"
  end
end
