defmodule KumaSanKanjiWeb.UserAuthTest do
  use KumaSanKanjiWeb.ConnCase, async: false

  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.Auth
  alias KumaSanKanjiWeb.UserAuth

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, KumaSanKanjiWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    {:ok, user} = User.sign_up("auth_test@example.com", "authuser", "password123")

    %{conn: conn, user: user}
  end

  describe "fetch_current_user/2" do
    test "assigns current_user based on user_id and token in session", %{conn: conn, user: user} do
      # Create session data
      session_data = Auth.create_session(conn, user)

      # Add to session
      conn =
        conn
        |> put_session(:user_id, session_data["user_id"])
        |> put_session(:token, session_data["token"])

      # Run the plug
      conn = UserAuth.fetch_current_user(conn, [])

      # Check user is assigned
      assert conn.assigns.current_user.id == user.id
    end

    test "assigns nil if user_id is missing", %{conn: conn} do
      conn = UserAuth.fetch_current_user(conn, [])
      assert conn.assigns.current_user == nil
    end

    test "assigns nil if token is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> put_session(:user_id, user.id)
        |> put_session(:token, "invalid_token")
        |> UserAuth.fetch_current_user([])

      assert conn.assigns.current_user == nil
    end
  end

  describe "require_authenticated_user/2" do
    test "redirects if user is not authenticated", %{conn: conn} do
      conn = conn |> UserAuth.require_authenticated_user([])
      assert conn.halted
      assert redirected_to(conn) == "/login"
    end

    test "does nothing if user is authenticated", %{conn: conn, user: user} do
      # Create session data and add to session
      session_data = Auth.create_session(conn, user)

      conn =
        conn
        |> put_session(:user_id, session_data["user_id"])
        |> put_session(:token, session_data["token"])
        |> assign(:current_user, user)
        |> UserAuth.require_authenticated_user([])

      refute conn.halted
    end
  end

  describe "log_in_user/2" do
    test "stores user data in session and redirects", %{conn: conn, user: user} do
      conn = UserAuth.log_in_user(conn, user)

      # Check session has user_id and token
      assert get_session(conn, :user_id)
      assert get_session(conn, :token)
    end

    test "clears existing session before login", %{conn: conn, user: user} do
      # Add some arbitrary data to session
      conn = put_session(conn, :test_key, "test_value")

      # Login user
      conn = UserAuth.log_in_user(conn, user)

      # Check old session data is gone
      assert get_session(conn, :test_key) == nil
    end
  end

  describe "log_out_user/1" do
    test "clears session and redirects to home page", %{conn: conn, user: user} do
      # Login user
      conn = UserAuth.log_in_user(conn, user)

      # Logout user
      conn = UserAuth.log_out_user(conn)

      # Check session is cleared
      assert get_session(conn, :user_id) == nil
      assert get_session(conn, :token) == nil

      # Check redirected to home
      assert redirected_to(conn) == "/"
    end
  end
end
