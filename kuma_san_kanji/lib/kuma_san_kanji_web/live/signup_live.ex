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
    # Validate email format
    with true <- is_valid_email?(email),
         # Validate password strength
         true <- is_valid_password?(password),
         # Attempt to create user
         {:ok, _user} <- User.sign_up(email, username, password) do
      # Redirect to login
      {:noreply,
       socket
       |> push_navigate(to: "/login?signup_success=true&email=" <> URI.encode_www_form(email))}
    else
      {:error, :invalid_email} ->
        {:noreply, socket |> assign(:form_error, "Please enter a valid email address")}

      {:error, :password_too_weak} ->
        {:noreply, socket |> assign(:form_error, "Password must be at least 8 characters and include a number")}

      {:error, error} ->
        error_msg = format_error(error)
        {:noreply, socket |> assign(:form_error, error_msg)}
    end
  end

  defp is_valid_email?(email) do
    email_regex = ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    if Regex.match?(email_regex, email), do: true, else: {:error, :invalid_email}
  end

  defp is_valid_password?(password) do
    if String.length(password) >= 8 and String.match?(password, ~r/[0-9]/),
      do: true,
      else: {:error, :password_too_weak}
  end

  defp format_error(error) do
    case error do
      %{errors: errors} when is_list(errors) ->
        Enum.map_join(errors, ", ", fn
          {field, {msg, _}} -> "#{field}: #{msg}"
          {field, msg} when is_binary(msg) -> "#{field}: #{msg}"
          error -> inspect(error)
        end)
      _ -> "An unexpected error occurred. Please try again."
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
          phx-change="validate"
          phx-submit="signup"
          class="mt-8 space-y-6"
        >
          <div :if={@form_error} class="bg-red-50 border border-sakura rounded-md p-4 text-sm font-katakana text-red-600">
            <%= @form_error %>
          </div>

          <div>
            <label for="email" class="block text-sm font-medium font-katakana text-gray-700">
              Email address
            </label>
            <div class="mt-1">
              <input
                type="email"
                id="email"
                name="email"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm"
                placeholder="you@example.com"
              />
            </div>
          </div>

          <div>
            <label for="username" class="block text-sm font-medium font-katakana text-gray-700">
              Username
            </label>
            <div class="mt-1">
              <input
                type="text"
                id="username"
                name="username"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm"
                placeholder="kuma_student"
              />
            </div>
          </div>

          <div>
            <label for="password" class="block text-sm font-medium font-katakana text-gray-700">
              Password
            </label>
            <div class="mt-1">
              <input
                type="password"
                id="password"
                name="password"
                required
                minlength="8"
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm"
                placeholder="Minimum 8 characters"
              />
              <p class="mt-2 text-xs text-gray-500 font-katakana">Password must be at least 8 characters and include a number</p>
            </div>
          </div>

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
