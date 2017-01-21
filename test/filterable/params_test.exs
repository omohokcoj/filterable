defmodule Filterable.ParamsTest do
  use ExUnit.Case
  import Filterable.Params

  setup_all do
    {:ok, %{name: "Tom", bio: "  was born", age: 23, friends: ["Jonny"],
            enemies: [], skills: %{"vox" => 1}, address: " "}}
  end

  test "returns filter value", params do
    value = filter_value(params, param: :name)
    assert value == "Tom"

    value = filter_value(params, param: :age)
    assert value == 23

    value = filter_value(params, param: :friends)
    assert value == ["Jonny"]
  end

  test "returns filter value with indifferent access", params do
    value = filter_value(params, param: "name")
    assert value == "Tom"
  end

  test "returns trimed value", params do
    value = filter_value(params, param: :bio, trim: true)
    assert value == "was born"

    value = filter_value(params, param: :skills, trim: true)
    assert value == %{"vox" => 1}
  end

  test "returns nilifed value", params do
    value = filter_value(params, param: :enemies)
    assert value == nil

    value = filter_value(params, param: :address, trim: true)
    assert value == nil
  end

  test "returns blank value", params do
    value = filter_value(params, param: :enemies, allow_blank: true)
    assert value == []

    value = filter_value(params, param: :address, allow_blank: true, trim: true)
    assert value == ""
  end

  test "returns default value", params do
    value = filter_value(params, param: :enemies, default: "cool")
    assert value == "cool"

    value = filter_value(params, param: :address, default: "cool", trim: true)
    assert value == "cool"
  end

  test "doesn't return default value when value present", params do
    value = filter_value(params, param: :name, default: "cool")
    assert value == "Tom"

    value = filter_value(params, param: :address, default: "cool", trim: false)
    assert value == " "
  end

  test "returns casted value", params do
    value = filter_value(params, param: :name, cast: &String.downcase/1)
    assert value == "tom"

    value = filter_value(params, param: :name, cast: [&String.downcase/1, &String.to_atom/1])
    assert value == :tom
  end
end
