defmodule KumaSanKanjiWeb.UserLiveAuth do
  @moduledoc """
  Module for handling LiveView authentication.
  """

  import Phoenix.Component
  import Phoenix.LiveView

  alias KumaSanKanji.Auth

  @doc """
  Assigns the current_user to the socket assigns.
  """
  def on_mount(:mount_current_user, _params, %{"user_id" => user_id, "token" => token} = _session, socket)
    when is_binary(user_id) and is_binary(token) do
    case verify_session_token(token) do
      {:ok, verified_user_id} when verified_user_id == user_id ->
        case Auth.get_user(user_id) do
          {:ok, user} ->
            {:cont, assign(socket, current_user: user)}
          _ ->
            {:cont, assign(socket, current_user: nil)}
        end
      _ ->
        {:cont, assign(socket, current_user: nil)}
    end
  end

  def on_mount(:mount_current_user, _params, _session, socket) do
    {:cont, assign(socket, current_user: nil)}
  end

  # Ensures user is authenticated. If not, redirects to login page.
  def on_mount(:ensure_authenticated, _params, %{"user_id" => user_id, "token" => token} = _session, socket)
    when is_binary(user_id) and is_binary(token) do
    case verify_session_token(token) do
      {:ok, verified_user_id} when verified_user_id == user_id ->
        case Auth.get_user(user_id) do
          {:ok, user} ->
            {:cont, assign(socket, current_user: user)}
          _ ->
            {:halt, redirect_to_login(socket)}
        end
      _ ->
        {:halt, redirect_to_login(socket)}
    end
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    {:halt, redirect_to_login(socket)}
  end

  # Helper function for verifying token
  defp verify_session_token(token) do
    Phoenix.Token.verify(KumaSanKanjiWeb.Endpoint, "user auth", token, max_age: 60 * 60 * 24 * 7) # 7 days
  end

  # Helper function for redirecting to login
  defp redirect_to_login(socket) do
    socket
    |> put_flash(:error, "You must log in to access this page.")
    |> redirect(to: "/login")
  end
end
