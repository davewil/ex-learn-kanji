defmodule KumaSanKanji.AuthTest do
  use KumaSanKanji.DataCase, async: true
  alias KumaSanKanji.Auth
  alias KumaSanKanji.Accounts.User

  describe "login/2" do
    setup do
      # Create a test user
      {:ok, user} = User.sign_up("test@example.com", "testuser", "password123")
      %{user: user}
    end

    test "returns user when credentials are valid", %{user: user} do
      assert {:ok, found_user} = Auth.login("test@example.com", "password123")
      assert found_user.id == user.id
      assert found_user.email == user.email
    end

    test "returns error when email is invalid" do
      assert {:error, _} = Auth.login("nonexistent@example.com", "password123")
    end

    test "returns error when password is invalid", %{user: _user} do
      assert {:error, _} = Auth.login("test@example.com", "wrongpassword")
    end
  end

  describe "get_user/1" do
    setup do
      {:ok, user} = User.sign_up("test2@example.com", "testuser2", "password123")
      %{user: user}
    end

    test "returns user when id exists", %{user: user} do
      assert {:ok, found_user} = Auth.get_user(user.id)
      assert found_user.id == user.id
    end

    test "returns error when id doesn't exist" do
      assert {:error, _} = Auth.get_user(Ecto.UUID.generate())
    end
  end

  describe "create_session/2" do
    setup do
      {:ok, user} = User.sign_up("test3@example.com", "testuser3", "password123")
      %{user: user}
    end

    test "creates a session with user id and token", %{user: user} do
      conn = %Plug.Conn{}
      session = Auth.create_session(conn, user)

      assert is_map(session)
      assert session["user_id"] == user.id
      assert is_binary(session["token"])
    end

    test "generates unique tokens for different users" do
      {:ok, user1} = User.sign_up("user1@example.com", "user1", "password123")
      {:ok, user2} = User.sign_up("user2@example.com", "user2", "password123")

      conn = %Plug.Conn{}
      session1 = Auth.create_session(conn, user1)
      session2 = Auth.create_session(conn, user2)

      assert session1["token"] != session2["token"]
    end
  end
end
