defmodule BookSearchWeb.BookControllerTest do
  use BookSearchWeb.ConnCase

  import BookSearch.BooksFixtures
  import BookSearch.AuthorsFixtures
  import BookSearch.TagsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  describe "index" do
    test "lists all books", %{conn: conn} do
      conn = get(conn, Routes.book_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Books"
    end
  end

  describe "new book" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.book_path(conn, :new))
      assert html_response(conn, 200) =~ "New Book"
    end
  end

  describe "create book" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.book_path(conn, :create), book: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.book_path(conn, :show, id)

      conn = get(conn, Routes.book_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Book"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.book_path(conn, :create), book: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Book"
    end

    test "create book with author association", %{conn: conn} do
      author = author_fixture()
      create_attrs_with_author = Map.put(@create_attrs, :author_id, author.id)

      conn = post(conn, Routes.book_path(conn, :create), book: create_attrs_with_author)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.book_path(conn, :show, id)

      conn = get(conn, Routes.book_path(conn, :show, id))
      assert html_response(conn, 200) =~ author.name
    end

    test "create book with tags", %{conn: conn} do
      tag1 = tag_fixture(name: "tag1")
      tag2 = tag_fixture(name: "tag2")

      create_attrs_with_tags = Map.put(@create_attrs, "tags", [tag1.id, tag2.id])

      conn = post(conn, Routes.book_path(conn, :create), book: create_attrs_with_tags)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.book_path(conn, :show, id)

      conn = get(conn, Routes.book_path(conn, :show, id))

      response = html_response(conn, 200)
      assert response =~ "Show Book"
      assert response =~ tag1.name
      assert response =~ tag2.name
    end

    test "create a book with associated book content", %{conn: conn} do
      # Create a map called "book_content" with a key-value pair for the "full_text" field
      book_content = %{full_text: "some full text"}
      # Add the "book_content" map to the "create_attrs" map as a value for the "book_content" key
      create_attrs_with_book_content = Map.put(@create_attrs, :book_content, book_content)

      # Make a POST request to the "Routes.book_path(conn, :create)" route with the modified "create_attrs_with_book_content" map as the request body
      conn = post(conn, Routes.book_path(conn, :create), book: create_attrs_with_book_content)

      # Assert that the response is a redirect, and that the "id" parameter is present in the redirect parameters
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.book_path(conn, :show, id)

      # Make a GET request to the "Routes.book_path(conn, :show, id)" route, using the "id" from the previous step
      conn = get(conn, Routes.book_path(conn, :show, id))

      # Assert that the response has a status code of 200 and that the response body contains the strings "Show Book" and the "full_text" value from the "book_content" map
      response = html_response(conn, 200)
      assert response =~ "Show Book"
      assert response =~ book_content.full_text
    end
  end

  describe "edit book" do
    setup [:create_book]

    test "renders form for editing chosen book", %{conn: conn, book: book} do
      conn = get(conn, Routes.book_path(conn, :edit, book))
      assert html_response(conn, 200) =~ "Edit Book"
    end
  end

  describe "update book" do
    setup [:create_book]

    test "redirects when data is valid", %{conn: conn, book: book} do
      conn = put(conn, Routes.book_path(conn, :update, book), book: @update_attrs)
      assert redirected_to(conn) == Routes.book_path(conn, :show, book)

      conn = get(conn, Routes.book_path(conn, :show, book))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, book: book} do
      conn = put(conn, Routes.book_path(conn, :update, book), book: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Book"
    end

    test "updates book with associated author", %{conn: conn, book: book} do
      original_author = author_fixture()
      updated_author = author_fixture()
      book = Map.put(book, :author_id, original_author.id)
      update_attrs_with_author = Map.put(@update_attrs, :author_id, updated_author.id)

      conn = put(conn, Routes.book_path(conn, :update, book), book: update_attrs_with_author)
      assert redirected_to(conn) == Routes.book_path(conn, :show, book)

      conn = get(conn, Routes.book_path(conn, :show, book))
      response = html_response(conn, 200)

      assert response =~ "some updated title"
      assert response =~ updated_author.name
    end

    test "update book with multiple tags", %{conn: conn, book: book} do
      original_tag1 = tag_fixture(name: "og_tag1")
      original_tag2 = tag_fixture(name: "og_tag2")
      updated_tag1 = tag_fixture(name: "new_tag1")
      updated_tag2 = tag_fixture(name: "new_tag2")

      book = Map.put(book, "tags", [original_tag1.id, original_tag2.id])
      update_attrs_with_tags = Map.put(@update_attrs, "tags", [updated_tag1.id, updated_tag2.id])

      conn = put(conn, Routes.book_path(conn, :update, book), book: update_attrs_with_tags)
      assert redirected_to(conn) == Routes.book_path(conn, :show, book)

      conn = get(conn, Routes.book_path(conn, :show, book))
      response = html_response(conn, 200)

      assert response =~ "some updated title"
      assert response =~ updated_tag1.name
      assert response =~ updated_tag2.name
    end
  end

  describe "delete book" do
    setup [:create_book]

    test "deletes chosen book", %{conn: conn, book: book} do
      conn = delete(conn, Routes.book_path(conn, :delete, book))
      assert redirected_to(conn) == Routes.book_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.book_path(conn, :show, book))
      end
    end
  end

  defp create_book(_) do
    book = book_fixture()
    %{book: book}
  end
end
