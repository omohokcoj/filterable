defmodule Filterable.User do
  use Ecto.Schema
  use Filterable.Phoenix.Model

  import Ecto.Query

  filterable share: false do
    filter name(query, value) do
      query |> where(name: ^value)
    end

    @options cast: :integer
    filter age(query, value) when value < 120 do
      query |> where(age: ^value)
    end
  end

  schema "users" do
    field :gender,         :string
    field :name,           :string
    field :surname,        :string
    field :street_address, :string
    field :city,           :string
    field :state,          :string
    field :zip_code,       :integer
    field :country,        :string
    field :phone,          :string
    field :birthday,       :date
    field :weight,         :float
    field :age,            :integer
    field :latlng,         {:array, :float}

    timestamps()
  end
end
