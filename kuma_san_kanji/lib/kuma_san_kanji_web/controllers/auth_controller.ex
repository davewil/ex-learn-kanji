defmodule KumaSanKanjiWeb.AuthController do
  use KumaSanKanjiWeb, :controller

  import KumaSanKanjiWeb.UserAuth

  alias KumaSanKanji.Auth

  def login(conn, %{"email" => email, "password" => password}) do
    case Auth.login(email, password) do
      {:ok, user} ->
        conn
        |> log_in_user(user)
        |> put_flash(:info, "Logged in successfully!")
        |> redirect(to: "/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: "/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> log_out_user()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
