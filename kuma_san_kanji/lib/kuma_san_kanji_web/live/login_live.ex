defmodule KumaSanKanjiWeb.LoginLive do
  use KumaSanKanjiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:form, to_form(%{"email" => "", "password" => ""}, as: "user"))}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      if params["signup_success"] == "true" && params["email"] do
        socket
        |> put_flash(:info, "Account created successfully! Please log in.")
        |> assign(:form, to_form(%{"email" => params["email"], "password" => ""}, as: "user"))
      else
        socket
      end

    {:noreply, socket}
  end

  # Template is now in login_live.html.heex
end
