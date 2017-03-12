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
    birthday: ~D[2017-01-01],
    human: "false"
  }

  describe "fetch param" do
    test "with atom key" do
      {:ok, value} = filter_value(@params, param: :name)
      assert value == "Tom"
    end

    test "with string key" do
      {:ok, value} = filter_value(%{"cool" => true}, param: :cool)
      assert value == true
    end
  end

  describe "fetch multimple params" do
    test "with atom key" do
      {:ok, value} = filter_value(@params, param: [:name, :age])
      assert value == %{age: 23, name: "Tom"}
    end

    test "with string key" do
      {:ok, value} = filter_value(%{"test" => true}, param: [:test, :bio])
      assert value == %{test: true, bio: nil}
    end
  end

  describe "fetch with keyword list param" do
    test "with single nested param" do
      {:ok, value} = filter_value(@params, param: [skills: [:piano]])
      assert value == %{piano: " "}
    end

    test "with multiple nested params" do
      {:ok, value} = filter_value(@params, param: [skills: [:piano], keywords: [:test]])
      assert value == %{keywords: %{test: nil}, skills: %{piano: " "}}
    end

    test "with deep nested params" do
      {:ok, value} = filter_value(@params, param: [skills: [piano: [:other]]])
      assert value == %{piano: %{other: nil}}

      {:ok, value} = filter_value(@params, param: [skills: [piano: [:other]], other: [:test, :test2]])
      assert value == %{other: nil, skills: %{piano: %{other: nil}}}
    end
  end

  describe "fetch nested params" do
    test "with atom key" do
      {:ok, value} = filter_value(@params, top_param: :skills, param: :vox)
      assert value == 1
    end

    test "with string key" do
      {:ok, value} = filter_value(@params, top_param: "skills", param: :vox)
      assert value == 1
    end
  end

  describe "trim params" do
    test "not nested string param" do
      {:ok, value} = filter_value(@params, param: :bio, trim: true)
      assert value == "was born"
    end

    test "string nested in map" do
      {:ok, value} = filter_value(@params, param: [:name, :bio], trim: true)
      assert value == %{bio: "was born", name: "Tom"}
    end

    test "return struct" do
      {:ok, value} = filter_value(@params, param: :birthday, trim: true)
      assert value == ~D[2017-01-01]
    end

    test "string inside list nested in map" do
      {:ok, value} = filter_value(@params, param: [:name, :friends], trim: true)
      assert value == %{name: "Tom", friends: ["Jonny"]}
    end
  end

  describe "nilify params" do
    test "empty list" do
      {:ok, value} = filter_value(@params, param: :enemies)
      assert value == nil
    end

    test "empty string" do
      {:ok, value} = filter_value(@params, param: :address, trim: true)
      assert value == nil
    end

    test "nested blank values" do
      {:ok, value} = filter_value(@params, param: :skills, trim: true)
      assert value == %{vox: 1, piano: nil}

      {:ok, value} = filter_value(@params, param: :keywords, trim: true)
      assert value == %{one: 1, two: nil}
    end
  end

  describe "allow blank params" do
    test "empty list" do
      {:ok, value} = filter_value(@params, param: :enemies, allow_blank: true)
      assert value == []
    end

    test "empty string" do
      {:ok, value} = filter_value(@params, param: :address, allow_blank: true, trim: true)
      assert value == ""
    end

    test "nested blank values" do
      {:ok, value} = filter_value(@params, param: :skills, trim: true, allow_blank: true)
      assert value == %{vox: 1, piano: ""}

      {:ok, value} = filter_value(@params, param: :keywords, trim: true, allow_blank: true)
      assert value == %{one: 1, two: [""]}
    end
  end

  describe "replace with default value" do
    test "string value" do
      {:ok, value} = filter_value(@params, param: :address, default: "cool", trim: true)
      assert value == "cool"
    end

    test "list value" do
      {:ok, value} = filter_value(@params, param: :address, default: ["cool"], trim: true)
      assert value == ["cool"]
    end

    test "struct value" do
      {:ok, value} = filter_value(@params, param: :address, default: ~D[2017-01-01], trim: true)
      assert value == ~D[2017-01-01]
    end

    test "nil value inside map" do
      {:ok, value} = filter_value(@params, param: :skills, trim: true, default: [piano: "test"])
      assert value == %{vox: 1, piano: "test"}
    end

    test "nil value inside keyword list" do
      {:ok, value} = filter_value(@params, param: :keywords, trim: true, default: [two: 2])
      assert value == %{one: 1, two: 2}
    end
  end

  describe "doesn't replace with default value" do
    test "value not nil" do
      {:ok, value} = filter_value(@params, param: :name, default: "cool")
      assert value == "Tom"
    end

    test "value false" do
      {:ok, value} = filter_value(@params, param: :human, default: "cool", cast: :boolean)
      assert value == false

      {:ok, value} = filter_value(@params, param: :human, default: ["test"], cast: :boolean)
      assert value == false
    end

    test "value nil" do
      {:ok, value} = filter_value(@params, param: :address, trim: true, default: [vox: "test"])
      assert value == nil
    end

    test "nested value not nil" do
      {:ok, value} = filter_value(@params, param: :skills, trim: true, default: [vox: "test"])
      assert value == %{vox: 1, piano: nil}

      {:ok, value} = filter_value(@params, param: :keywords, trim: true, default: [one: "not one"])
      assert value == %{one: 1, two: nil}
    end

    test "default value not set" do
      {:ok, value} = filter_value(@params, param: :keywords, trim: true, default: ["not one"])
      assert value == %{one: 1, two: nil}

      {:ok, value} = filter_value(@params, param: :skills, trim: true, default: ["not one"])
      assert value == %{vox: 1, piano: nil}
    end
  end

  describe "cast param" do
    test "using function" do
      {:ok, value} = filter_value(@params, param: :name, cast: &String.downcase/1)
      assert value == "tom"
    end

    test "using list of functions" do
      {:ok, value} = filter_value(@params, param: :name, cast: [&String.downcase/1, &String.to_atom/1])
      assert value == :tom
    end

    test "using atom param" do
      {:ok, value} = filter_value(@params, param: :keywords, trim: true, cast: :string)
      assert value == %{one: "1", two: nil}

      {:ok, value} = filter_value(@params, param: :friends, trim: true, cast: :integer, allow_blank: true)
      assert value == []
    end

    test "using wrong cast param" do
      {:ok, value} = filter_value(@params, param: :keywords, trim: true, cast: %{})
      assert value == %{one: 1, two: nil}
    end

    test "returns casted struct value" do
      {:ok, value} = filter_value(@params, param: :birthday, cast: :string)
      assert value == "2017-01-01"

      {:ok, value} = filter_value(@params, param: :birthday, cast: &Filterable.Cast.string/1)
      assert value == "2017-01-01"
    end

    test "returns casted map value" do
      {:ok, value} = filter_value(@params, param: :skills, cast: :integer)
      assert value == %{vox: 1, piano: nil}
    end

    test "returns error if unable to cast" do
      assert {:error, "Unable to cast 1 to date"} = filter_value(@params, param: :keywords, trim: true, cast: :date, cast_errors: true)
      assert {:error, "Unable to cast 1 using &Filterable.Cast.date/1"} =
        filter_value(@params, param: :keywords, trim: true, cast: &Filterable.Cast.date/1, cast_errors: true)
    end

    test "returns error if unable to cast with list" do
      assert {:error, "Unable to cast ~D[2017-01-01] to integer"} =
        filter_value(@params, param: :birthday, cast: [:integer], cast_errors: true)
    end

    test "returns custom error message" do
      assert {:error, :invalid_format} =
        filter_value(@params, param: :friends, trim: true, cast: &NaiveDateTime.from_iso8601/1, cast_errors: true)
    end

    test "returns original list value" do
      assert {:ok, ["Jonny "]} = filter_value(@params, param: :friends, cast: [:string], cast_errors: true)
    end

    test "returns :ok if cast_errors false" do
      assert {:ok, nil} = filter_value(@params, param: :birthday, cast: [:integer], cast_errors: false)
    end
  end
end
