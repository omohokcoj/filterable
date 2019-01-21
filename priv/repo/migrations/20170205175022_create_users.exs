defmodule Filterable.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :gender,         :string
      add :name,           :string
      add :surname,        :string
      add :street_address, :string
      add :city,           :string
      add :state,          :string
      add :country,        :string
      add :phone,          :string
      add :birthday,       :date
      add :weight,         :float
      add :age,            :integer
      add :latlng,         {:array, :float}
      add :subscribed,     :boolean

      timestamps()
    end
  end
end
