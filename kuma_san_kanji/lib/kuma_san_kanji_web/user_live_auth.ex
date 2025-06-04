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
    case Auth.get_user_from_session(user_id, token) do
      {:ok, user} ->
        {:cont, assign(socket, current_user: user)}
      {:error, _} ->
        {:cont, assign(socket, current_user: nil)}
    end
  end

  def on_mount(:mount_current_user, _params, _session, socket) do
    {:cont, assign(socket, current_user: nil)}
  end

  # Ensures user is authenticated. If not, redirects to login page.
  def on_mount(:ensure_authenticated, _params, %{"user_id" => user_id, "token" => token} = _session, socket)
    when is_binary(user_id) and is_binary(token) do
    case Auth.get_user_from_session(user_id, token) do
      {:ok, user} ->
        {:cont, assign(socket, current_user: user)}
      {:error, _} ->
        {:halt, redirect_to_login(socket)}
    end
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    {:halt, redirect_to_login(socket)}
  end

  # Helper function for redirecting to login
  defp redirect_to_login(socket) do
    socket =
      if Map.has_key?(socket.assigns, :flash) do
        socket
      else
        assign(socket, :flash, %{})
      end

    socket
    |> put_flash(:error, "You must log in to access this page.")
    |> redirect(to: "/login")
  end
end
