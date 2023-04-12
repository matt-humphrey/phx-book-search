alias BookSearch.Authors
alias BookSearch.Books
alias BookSearch.Books.Book
alias BookSearch.Repo

# Author Without Books
Authors.create_author(%{name: Faker.Lorem.sentence(10)})

# Book Without Author
Books.create_book(%{title: Faker.Lorem.sentence(10)})

# Author With A Book
{:ok, author} = Authors.create_author(%{name: Faker.Lorem.sentence(10)})

Enum.each(1..10, fn _ ->
  %Book{}
  |> Book.changeset(%{title: Faker.Lorem.sentence(10)})
  |> Ecto.Changeset.put_assoc(:author, author)
  |> Repo.insert!()
end)
