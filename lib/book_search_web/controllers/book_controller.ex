defmodule BookSearchWeb.BookController do
  use BookSearchWeb, :controller

  alias BookSearch.Books
  alias BookSearch.Books.Book
  alias BookSearch.Authors
  alias BookSearch.Tags

  def index(conn, _params) do
    books = Books.list_books() |> BookSearch.Repo.preload([:author])
    render(conn, "index.html", books: books)
  end

  def new(conn, _params) do
    changeset = Books.change_book(%Book{})
    authors = Authors.list_authors()
    render(conn, "new.html", changeset: changeset, authors: authors)
  end

  def create(conn, %{"book" => book_params}) do
    {tag_ids, book_params} = Map.pop(book_params, "tags", [])
    tags = Enum.map(tag_ids, &Tags.get_tag!/1)

    case Books.create_book(book_params, tags) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: Routes.book_path(conn, :show, book))

      {:error, %Ecto.Changeset{} = changeset} ->
        authors = Authors.list_authors()
        render(conn, "new.html", changeset: changeset, authors: authors)
    end
  end

  def show(conn, %{"id" => id}) do
    book = Books.get_book!(id) |> BookSearch.Repo.preload([:author, :tags])
    render(conn, "show.html", book: book)
  end

  def edit(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    tag_ids = Enum.map(book.tags, & &1.id)

    changeset = Books.change_book(book)
    authors = Authors.list_authors()
    render(conn, "edit.html", book: book, changeset: changeset, authors: authors, tag_ids: tag_ids)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Books.get_book!(id)
    {tag_ids, book_params} = Map.pop(book_params, "tags", [])
    tags = Enum.map(tag_ids, &Tags.get_tag!/1)

    case Books.update_book(book, book_params, tags) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: Routes.book_path(conn, :show, book))

      {:error, %Ecto.Changeset{} = changeset} ->
        authors = Authors.list_authors()
        render(conn, "edit.html", book: book, changeset: changeset, authors: authors)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    {:ok, _book} = Books.delete_book(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: Routes.book_path(conn, :index))
  end
end
