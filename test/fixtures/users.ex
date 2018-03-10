defmodule Filterable.Fixtures.Users do
  @moduledoc false

  @data [
    %{
      id: 1,
      age: 22,
      birthday: ~D[1968-03-28],
      city: "Brattleboro",
      country: "US",
      gender: "male",
      latlng: [42.823378, -72.689639],
      name: "Martin",
      phone: "802-713-0025",
      state: "VT",
      street_address: "3224 Selah Way",
      surname: "Mejia",
      weight: 89.9
    },
    %{
      id: 2,
      age: 25,
      birthday: ~D[1974-06-15],
      city: "Huntington",
      country: "US",
      gender: "female",
      latlng: [38.464308, -82.454761],
      name: "Debbie",
      phone: "304-521-7011",
      state: "WV",
      street_address: "3107 Columbia Mine Road",
      surname: "Judson",
      weight: 90.5
    },
    %{
      id: 3,
      age: 40,
      birthday: ~D[1989-06-04],
      city: "Bakersfield",
      country: "US",
      gender: "female",
      latlng: [35.358853, -118.989485],
      name: "Margie",
      phone: "661-868-6211",
      state: "CA",
      street_address: "684 Gateway Avenue",
      surname: "Chaney",
      weight: 87.9
    },
    %{
      id: 4,
      age: 55,
      birthday: ~D[1958-09-15],
      city: "Memphis",
      country: "US",
      gender: "male",
      latlng: [35.256051, -89.943739],
      name: "Jerry",
      phone: "901-494-4084",
      state: "TN",
      street_address: "4782 Lightning Point Drive",
      surname: "Smith",
      weight: 92.2
    },
    %{
      id: 5,
      age: 32,
      birthday: ~D[1985-09-27],
      city: "Grand Rapids",
      country: "US",
      gender: "female",
      latlng: [42.843924, -85.666829],
      name: "Gloria",
      phone: "269-335-0490",
      state: "MI",
      street_address: "2603 Shingleton Road",
      surname: "Lewis",
      weight: 101.2
    },
    %{
      id: 6,
      age: 74,
      birthday: ~D[1943-08-09],
      city: "Baton Rouge",
      country: "US",
      gender: "female",
      latlng: [30.368472, -91.107493],
      name: "Martha",
      phone: "225-338-3595",
      state: "LA",
      street_address: "21 Washburn Street",
      surname: "Valentine",
      weight: 78.0
    },
    %{
      id: 7,
      age: 44,
      birthday: ~D[1968-06-09],
      city: "Fayetteville",
      country: "US",
      gender: "female",
      latlng: [36.03746, -93.927881],
      name: "Cynthia",
      phone: "479-305-3711",
      state: "AR",
      street_address: "3792 Green Hill Road",
      surname: "Crowley",
      weight: 60.9
    },
    %{
      id: 8,
      age: 39,
      birthday: ~D[1960-08-15],
      city: "Sparrevohn A.F.S.",
      country: "US",
      gender: "male",
      latlng: [61.123828, -155.651961],
      name: "Barry",
      phone: "907-731-7755",
      state: "AK",
      street_address: "553 Timbercrest Road",
      surname: "Sparks",
      weight: 97.1
    },
    %{
      id: 9,
      age: 27,
      birthday: ~D[1956-05-12],
      city: "Bishopville",
      country: "US",
      gender: "male",
      latlng: [34.188195, -80.278694],
      name: "Joe",
      phone: "803-588-1096",
      state: "SC",
      street_address: "1342 Java Lane",
      surname: "Davis",
      weight: 95.0
    },
    %{
      id: 10,
      age: 22,
      birthday: ~D[1989-04-10],
      city: "Conyers",
      country: "US",
      gender: "female",
      latlng: [33.749272, -83.94778],
      name: "Cindy",
      phone: "770-922-1980",
      state: "GA",
      street_address: "1532 Smith Road",
      surname: "Keyes",
      weight: 63.7
    }
  ]

  def seed do
    Enum.each(@data, fn data ->
      changeset = Ecto.Changeset.cast(%Filterable.User{}, data, Map.keys(data))
      Filterable.Repo.insert!(changeset)
    end)
  end
end
