use Mix.Config

config :filterable, Filterable.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "filterable_test",
  username: "postgres",
  password: "postgres"

config :logger, level: :info
