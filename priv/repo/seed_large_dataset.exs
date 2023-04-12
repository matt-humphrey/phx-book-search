alias BookSearch.Authors
alias BookSearch.Books
alias BookSearch.Books.Book
alias BookSearch.Repo

# Authors Without Books
Enum.each(1..10, fn _ ->
  Authors.create_author(%{name: Faker.Person.name()})
end)

# Books Without Authors
Enum.each(1..10, fn _ ->
  Books.create_book(%{title: Faker.Lorem.sentence()})
end)

Enum.each(1..10, fn _ ->
  {:ok, author} = Authors.create_author(%{name: Faker.Person.name()})

  Enum.each(1..10, fn _ ->
    %Book{}
    |> Book.changeset(%{title: Faker.Lorem.sentence()})
    |> Ecto.Changeset.put_assoc(:author, author)
    |> Repo.insert!()
  end)
end)
