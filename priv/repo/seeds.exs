Code.require_file("test/fixtures/users.ex")

Filterable.Repo.start_link()
Filterable.Fixtures.Users.seed()
