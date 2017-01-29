defmodule Filterable.ParamsTest do
  use ExUnit.Case
  import Filterable.Params

  setup_all do
    {:ok, %{name: "Tom", bio: "  was born", age: 23, friends: ["Jonny "],
            enemies: [], skills: %{"vox" => 1, "piano" => " "}, address: " ",
            keywords: [one: 1, two: ["  "]]}}
  end

  test "returns filter value", params do
    value = filter_value(params, param: :name)
    assert value == "Tom"

    value = filter_value(%{"cool" => true}, param: :cool)
    assert value == true

    value = filter_value(params, param: :friends)
    assert value == ["Jonny "]
  end

  test "returns map of filter values", params do
    value = filter_value(params, param: [:name, :age])
    assert value == %{age: 23, name: "Tom"}

    value = filter_value(params, param: [:name, :bio])
    assert value == %{bio: "  was born", name: "Tom"}
  end

  test "returns filter value with indifferent access", params do
    value = filter_value(params, param: "name")
    assert value == "Tom"
  end

  test "returns trimed value", params do
    value = filter_value(params, param: :bio, trim: true)
    assert value == "was born"

    value = filter_value(params, param: :skills, trim: true, allow_blank: true)
    assert value == %{"vox" => 1, "piano" => ""}

    value = filter_value(params, param: [:name, :bio], trim: true)
    assert value == %{bio: "was born", name: "Tom"}

    value = filter_value(params, param: [:name, :friends], trim: true)
    assert value == %{name: "Tom", friends: ["Jonny"]}

    value = filter_value(params, param: :keywords, trim: true, allow_blank: true)
    assert value == [one: 1, two: [""]]
  end

  test "returns nilifed value", params do
    value = filter_value(params, param: :enemies)
    assert value == nil

    value = filter_value(params, param: :address, trim: true)
    assert value == nil

    value = filter_value(params, param: :skills, trim: true)
    assert value == %{"vox" => 1}

    value = filter_value(params, param: :keywords, trim: true)
    assert value == [one: 1]
  end

  test "returns blank value", params do
    value = filter_value(params, param: :enemies, allow_blank: true)
    assert value == []

    value = filter_value(params, param: :address, allow_blank: true, trim: true)
    assert value == ""

    value = filter_value(params, param: :skills, trim: true, allow_blank: true)
    assert value == %{"vox" => 1, "piano" => ""}

    value = filter_value(params, param: :keywords, trim: true, allow_blank: true)
    assert value == [one: 1, two: [""]]
  end

  test "returns default value", params do
    value = filter_value(params, param: :enemies, default: "cool")
    assert value == "cool"

    value = filter_value(params, param: :address, default: "cool", trim: true)
    assert value == "cool"

    value = filter_value(params, param: :skills, trim: true, default: %{"piano" => "test"})
    assert value == %{"vox" => 1, "piano" => "test"}

    value = filter_value(params, param: :skills, trim: true, default: [piano: "test"])
    assert value == %{"vox" => 1, piano: "test"}

    value = filter_value(params, param: :keywords, trim: true, default: [two: 2])
    assert value == [two: 2, one: 1]
  end

  test "doesn't return default value when value present", params do
    value = filter_value(params, param: :name, default: "cool")
    assert value == "Tom"

    value = filter_value(params, param: :address, default: "cool", trim: false)
    assert value == " "

    value = filter_value(params, param: :skills, trim: true, default: %{"vox" => "test"})
    assert value == %{"vox" => 1}

    value = filter_value(params, param: :skills, trim: true, default: ["test"])
    assert value == %{"vox" => 1}

    value = filter_value(params, param: :keywords, trim: true, default: [one: "not one"])
    assert value == [one: 1]

    value = filter_value(params, param: :keywords, trim: true, default: ["not one"])
    assert value == [one: 1]
  end

  test "returns casted value", params do
    value = filter_value(params, param: :name, cast: &String.downcase/1)
    assert value == "tom"

    value = filter_value(params, param: :name, cast: [&String.downcase/1, &String.to_atom/1])
    assert value == :tom

    value = filter_value(params, param: :skills, trim: true, cast: &Integer.to_string/1)
    assert value == %{"vox" => "1"}

    value = filter_value(params, param: :keywords, trim: true, cast: &Integer.to_string/1)
    assert value == [one: "1"]
  end
end
