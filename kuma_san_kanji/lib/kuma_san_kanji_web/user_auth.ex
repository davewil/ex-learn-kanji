defmodule KumaSanKanjiWeb.UserAuth do
  @moduledoc """
  Plug for handling user authentication via session.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias KumaSanKanji.Auth

  @doc """
  A plug that loads the current user from the session.
  """
  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    token = get_session(conn, :token)

    if user_id && token do
      case Auth.get_user_from_session(user_id, token) do
        {:ok, user} -> assign(conn, :current_user, user)
        {:error, _} -> assign(conn, :current_user, nil)
      end
    else
      assign(conn, :current_user, nil)
    end
  end

  @doc """
  A plug that ensures the user is authenticated.
  If not, redirects to the login page.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> fetch_flash()
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  @doc """
  Logs the user in.
  """
  def log_in_user(conn, user) do
    # Store the user ID in the session
    session_data = Auth.create_session(conn, user)

    conn
    |> renew_session()
    |> put_session(:user_id, session_data["user_id"])
    |> put_session(:token, session_data["token"])
    |> configure_session(renew: true)
  end

  @doc """
  Logs the user out by clearing the session.
  """
  def log_out_user(conn) do
    conn
    |> renew_session()
    |> redirect(to: "/")
  end

  # Helper to renew the session and remove potentially sensitive data
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end
end
