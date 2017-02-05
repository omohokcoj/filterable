defmodule Filterable.User do
  use Ecto.Schema

  use Filterable.Phoenix.Model

  filterable Filterable.UserModelFilters

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
