Filterable.Repo.start_link()

Filterable.Repo
|> Ecto.Adapters.SQL.query!("COPY users FROM '#{Path.absname("test/fixtures/users.csv")}' WITH CSV HEADER")
