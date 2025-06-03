defmodule KumaSanKanjiWeb.UserLiveAuthTest do
  use KumaSanKanjiWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.Auth
  alias KumaSanKanjiWeb.UserLiveAuth

  describe "on_mount :mount_current_user" do
    setup %{conn: conn} do
      {:ok, user} = User.sign_up("liveauth@example.com", "liveuser", "password123")
      session_data = Auth.create_session(conn, user)

      %{user: user, session_data: session_data}
    end

    test "assigns current_user if session is valid", %{conn: conn, user: user, session_data: session_data} do
      session = %{"user_id" => session_data["user_id"], "token" => session_data["token"]}
      {:cont, new_socket} = UserLiveAuth.on_mount(:mount_current_user, %{}, session, %Phoenix.LiveView.Socket{})

      assert new_socket.assigns.current_user.id == user.id
    end

    test "assigns nil if session is invalid", %{conn: conn} do
      invalid_session = %{"user_id" => Ecto.UUID.generate(), "token" => "invalid_token"}

      {:cont, new_socket} = UserLiveAuth.on_mount(:mount_current_user, %{}, invalid_session, %Phoenix.LiveView.Socket{})

      assert new_socket.assigns.current_user == nil
    end

    test "assigns nil if session is empty" do
      {:cont, new_socket} = UserLiveAuth.on_mount(:mount_current_user, %{}, %{}, %Phoenix.LiveView.Socket{})

      assert new_socket.assigns.current_user == nil
    end
  end

  describe "on_mount :ensure_authenticated" do
    setup %{conn: conn} do
      {:ok, user} = User.sign_up("liveauth2@example.com", "liveuser2", "password123")
      session_data = Auth.create_session(conn, user)

      socket = %Phoenix.LiveView.Socket{}

      %{user: user, session_data: session_data, socket: socket}
    end

    test "continues if user is authenticated", %{user: user, session_data: session_data, socket: socket} do
      session = %{"user_id" => session_data["user_id"], "token" => session_data["token"]}

      {:cont, new_socket} = UserLiveAuth.on_mount(:ensure_authenticated, %{}, session, socket)

      assert new_socket.assigns.current_user.id == user.id
    end

    test "halts and redirects if user is not authenticated", %{socket: socket} do
      {:halt, %{redirected: {:redirect, %{to: path}}}} =
        UserLiveAuth.on_mount(:ensure_authenticated, %{}, %{}, socket)

      assert path == "/login"
    end

    test "halts and redirects if token is invalid", %{user: user, socket: socket} do
      invalid_session = %{"user_id" => user.id, "token" => "invalid_token"}

      {:halt, %{redirected: {:redirect, %{to: path}}}} =
        UserLiveAuth.on_mount(:ensure_authenticated, %{}, invalid_session, socket)

      assert path == "/login"
    end
  end
end
