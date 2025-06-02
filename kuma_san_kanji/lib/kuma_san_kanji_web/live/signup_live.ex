defmodule KumaSanKanjiWeb.SignupLive do
  use KumaSanKanjiWeb, :live_view
  alias KumaSanKanji.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> assign(:form, to_form(%{"email" => "", "username" => "", "password" => ""}))
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("validate", %{"email" => email, "username" => username, "password" => password}, socket) do
    {:noreply, 
     assign(socket, :form, to_form(%{"email" => email, "username" => username, "password" => password}))}
  end
  @impl true
  def handle_event("signup", %{"email" => email, "username" => username, "password" => password}, socket) do
    case User.sign_up(email, username, password) do
      {:ok, _user} ->
        # Redirect to an endpoint that will log in the user and redirect to home page
        {:noreply,
         socket
         |> push_navigate(to: "/login?signup_success=true&email=" <> URI.encode_www_form(email))}

      {:error, error} ->
        error_msg = case error do
          %{errors: errors} when is_list(errors) ->
            Enum.map_join(errors, ", ", fn
              {field, {msg, _}} -> "#{field}: #{msg}"
              {field, msg} when is_binary(msg) -> "#{field}: #{msg}"
              error -> inspect(error)
            end)
          _ -> "An unexpected error occurred. Please try again."
        end
        
        {:noreply, 
         socket
         |> assign(:form_error, error_msg)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 sm:py-20 lg:px-8 xl:px-20 xl:py-24">
      <div class="mx-auto max-w-md">
        <h1 class="text-3xl font-bold tracking-tight text-zinc-900 sm:text-4xl">
          Sign Up
        </h1>
        <p class="mt-3 text-lg text-zinc-600">
          Create an account to track your progress and save your favorite kanji.
        </p>
        
        <.form
          for={@form}
          phx-change="validate"
          phx-submit="signup"
          class="mt-8 space-y-6"
        >
          <div :if={@form_error} class="bg-red-50 border border-red-200 rounded-md p-4 text-sm text-red-600">
            <%= @form_error %>
          </div>
          
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">
              Email address
            </label>
            <div class="mt-1">
              <input
                type="email"
                id="email"
                name="email"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                placeholder="you@example.com"
              />
            </div>
          </div>
          
          <div>
            <label for="username" class="block text-sm font-medium text-gray-700">
              Username
            </label>
            <div class="mt-1">
              <input
                type="text"
                id="username"
                name="username"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                placeholder="kuma_student"
              />
            </div>
          </div>
          
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">
              Password
            </label>
            <div class="mt-1">
              <input
                type="password"
                id="password"
                name="password"
                required
                minlength="8"
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                placeholder="Minimum 8 characters"
              />
              <p class="mt-2 text-xs text-gray-500">Password must be at least 8 characters</p>
            </div>
          </div>
          
          <div>
            <button
              type="submit"
              class="w-full rounded-md bg-blue-600 py-2.5 px-3.5 text-sm font-medium text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              Create account
            </button>
          </div>
          
          <div class="text-center text-sm">
            <p class="text-gray-600">
              Already have an account?
              <.link navigate={~p"/login"} class="font-semibold text-blue-600 hover:text-blue-500">
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
