defmodule KumaSanKanjiWeb.SignupLive do
  use KumaSanKanjiWeb, :live_view
  alias KumaSanKanji.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    form = AshPhoenix.Form.for_create(User, :sign_up, as: "user")

    {:ok,
     socket
     |> assign(:ash_form, form)
     |> assign(:form, to_form(form))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.ash_form, user_params)
    {:noreply, socket |> assign(:ash_form, form) |> assign(:form, to_form(form))}
  end

  @impl true
  def handle_event("signup", %{"user" => user_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.ash_form, params: user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> push_navigate(
           to: "/login?signup_success=true&email=" <> URI.encode_www_form(user_params["email"])
         )}

      {:error, form} ->
        {:noreply, socket |> assign(:ash_form, form) |> assign(:form, to_form(form))}
    end
  end

  # Template is now in signup_live.html.heex
end
