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
         |> push_navigate(to: "/login?signup_success=true&email=" <> URI.encode_www_form(user_params["email"]))}
      {:error, form} ->
        {:noreply, socket |> assign(:ash_form, form) |> assign(:form, to_form(form))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 sm:py-20 lg:px-8 xl:px-20 xl:py-24">
      <div class="mx-auto max-w-md">
        <h1 class="text-3xl font-bold tracking-tight font-display text-accent-blue sm:text-4xl">
          Sign Up <span class="text-sakura-dark">登録</span>
        </h1>
        <p class="mt-3 text-lg font-katakana text-gray-600">
          Create an account to track your progress and save your favorite kanji.
        </p>

        <.form
          for={@form}
          as={:user}
          phx-change="validate"
          phx-submit="signup"
          class="mt-8 space-y-6"
        >
          <.input field={@form[:email]} label="Email address" required class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm" placeholder="you@example.com" />

          <.input field={@form[:username]} label="Username" required class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm" placeholder="kuma_student" />

          <.input field={@form[:password]} label="Password" type="password" required minlength="8" class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm" placeholder="Minimum 8 characters" />
          <p class="mt-2 text-xs text-gray-500 font-katakana">Password must be at least 8 characters and include a number</p>

          <div>
            <button
              type="submit"
              class="w-full rounded-md bg-sakura py-2.5 px-3.5 text-sm font-katakana font-medium text-white shadow-sm hover:bg-sakura-dark focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sakura"
            >
              Create account
            </button>
          </div>

          <div class="text-center text-sm">
            <p class="text-gray-600 font-katakana">
              Already have an account?
              <.link navigate={~p"/login"} class="font-semibold text-accent-blue hover:text-accent-blue/80">
                Log in
              </.link>
            </p>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
