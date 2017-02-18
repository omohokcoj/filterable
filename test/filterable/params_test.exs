defmodule Filterable.ParamsTest do
  use ExUnit.Case
  import Filterable.Params

  @params %{
    name: "Tom",
    bio: "  was born",
    age: 23,
    friends: ["Jonny "],
    enemies: [],
    skills: %{"vox" => 1, "piano" => " "},
    address: " ",
    keywords: [one: 1, two: ["  "]],
    birthday: ~D[2017-01-01]
  }

  describe "fetch param" do
    test "with atom key" do
      value = filter_value(@params, param: :name)
      assert value == "Tom"
    end

    test "with string key" do
      value = filter_value(%{"cool" => true}, param: :cool)
      assert value == true
    end
  end

  describe "fetch multimple params" do
    test "with atom key" do
      value = filter_value(@params, param: [:name, :age])
      assert value == %{age: 23, name: "Tom"}
    end

    test "with string key" do
      value = filter_value(%{"test" => true}, param: [:test, :bio])
      assert value == %{test: true, bio: nil}
    end
  end

  describe "fetch nested params" do
    test "with atom key" do
      value = filter_value(@params, top_param: :skills, param: :vox)
      assert value == 1
    end

    test "with string key" do
      value = filter_value(@params, top_param: "skills", param: :vox)
      assert value == 1
    end
  end

  describe "trim params" do
    test "not nested string param" do
      value = filter_value(@params, param: :bio, trim: true)
      assert value == "was born"
    end

    test "string nested in map" do
      value = filter_value(@params, param: [:name, :bio], trim: true)
      assert value == %{bio: "was born", name: "Tom"}
    end

    test "return struct" do
      value = filter_value(@params, param: :birthday, trim: true)
      assert value == ~D[2017-01-01]
    end

    test "string inside list nested in map" do
      value = filter_value(@params, param: [:name, :friends], trim: true)
      assert value == %{name: "Tom", friends: ["Jonny"]}
    end
  end

  describe "nilify params" do
    test "empty list" do
      value = filter_value(@params, param: :enemies)
      assert value == nil
    end

    test "empty string" do
      value = filter_value(@params, param: :address, trim: true)
      assert value == nil
    end

    test "nested blank values" do
      value = filter_value(@params, param: :skills, trim: true)
      assert value == %{vox: 1, piano: nil}

      value = filter_value(@params, param: :keywords, trim: true)
      assert value == %{one: 1, two: nil}
    end
  end

  describe "allow blank params" do
    test "empty list" do
      value = filter_value(@params, param: :enemies, allow_blank: true)
      assert value == []
    end

    test "empty string" do
      value = filter_value(@params, param: :address, allow_blank: true, trim: true)
      assert value == ""
    end

    test "nested blank values" do
      value = filter_value(@params, param: :skills, trim: true, allow_blank: true)
      assert value == %{vox: 1, piano: ""}

      value = filter_value(@params, param: :keywords, trim: true, allow_blank: true)
      assert value == %{one: 1, two: [""]}
    end
  end

  describe "replace with default value" do
    test "string value" do
      value = filter_value(@params, param: :address, default: "cool", trim: true)
      assert value == "cool"
    end

    test "list value" do
      value = filter_value(@params, param: :address, default: ["cool"], trim: true)
      assert value == ["cool"]
    end

    test "struct value" do
      value = filter_value(@params, param: :address, default: ~D[2017-01-01], trim: true)
      assert value == ~D[2017-01-01]
    end

    test "nil value inside map" do
      value = filter_value(@params, param: :skills, trim: true, default: [piano: "test"])
      assert value == %{vox: 1, piano: "test"}
    end

    test "nil value inside keyword list" do
      value = filter_value(@params, param: :keywords, trim: true, default: [two: 2])
      assert value == %{one: 1, two: 2}
    end
  end

  describe "doesn't replace with default value" do
    test "value not nil" do
      value = filter_value(@params, param: :name, default: "cool")
      assert value == "Tom"
    end

    test "nested value not nil" do
      value = filter_value(@params, param: :skills, trim: true, default: [vox: "test"])
      assert value == %{vox: 1, piano: nil}

      value = filter_value(@params, param: :keywords, trim: true, default: [one: "not one"])
      assert value == %{one: 1, two: nil}
    end

    test "default value not set" do
      value = filter_value(@params, param: :keywords, trim: true, default: ["not one"])
      assert value == %{one: 1, two: nil}

      value = filter_value(@params, param: :skills, trim: true, default: ["not one"])
      assert value == %{vox: 1, piano: nil}
    end
  end

  describe "cast param" do
    test "using function" do
      value = filter_value(@params, param: :name, cast: &String.downcase/1)
      assert value == "tom"
    end

    test "using list of functions" do
      value = filter_value(@params, param: :name, cast: [&String.downcase/1, &String.to_atom/1])
      assert value == :tom
    end

    test "using atom param" do
      value = filter_value(@params, param: :keywords, trim: true, cast: :string)
      assert value == %{one: "1", two: nil}

      value = filter_value(@params, param: :friends, trim: true, cast: :integer, allow_blank: true)
      assert value == []
    end

    test "using wrong cast param" do
      value = filter_value(@params, param: :keywords, trim: true, cast: %{})
      assert value == %{one: 1, two: nil}
    end

    test "returns casted struct value" do
      value = filter_value(@params, param: :birthday, cast: :string)
      assert value == "2017-01-01"
    end

    test "raises error using bang cast function" do
      assert_raise Filterable.CastError, "Unable to cast 1 to date", fn ->
        filter_value(@params, param: :keywords, trim: true, cast: :date!)
      end
    end
  end
end
