defmodule Filterable.User do
  @moduledoc false

  use Ecto.Schema
  use Filterable.Phoenix.Model

  import Ecto.Query

  filterable share: false do
    field :name

    limitable limit: 20

    @options cast: :integer
    filter age(query, value) when value < 120 do
      query |> where(age: ^value)
    end
  end

  schema "users" do
    field :gender, :string
    field :name, :string
    field :surname, :string
    field :street_address, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :phone, :string
    field :birthday, :date
    field :weight, :float
    field :age, :integer
    field :latlng, {:array, :float}
    field :subscribed, :boolean

    timestamps()
  end
end
