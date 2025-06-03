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

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 sm:py-20 lg:px-8 xl:px-20 xl:py-24">
      <div class="mx-auto max-w-md">
        <h1 class="text-3xl font-bold tracking-tight font-display text-accent-blue sm:text-4xl">
          Log In <span class="text-sakura-dark">ログイン</span>
        </h1>
        <p class="mt-3 text-lg text-gray-600 font-katakana">
          Welcome back! Log in to continue your kanji learning journey.
        </p>

        <.form
          for={@form}
          action={~p"/login"}
          method="post"
          class="mt-8 space-y-6"
        >
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
                value={@form[:email].value}
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm"
                placeholder="you@example.com"
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
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent-blue focus:ring-accent-blue sm:text-sm"
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              class="w-full rounded-md bg-accent-blue py-2.5 px-3.5 text-sm font-katakana font-medium text-white shadow-sm hover:bg-accent-blue/80 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent-blue"
            >
              Log in
            </button>
          </div>

          <div class="text-center text-sm">
            <p class="text-gray-600 font-katakana">
              Don't have an account?
              <.link navigate={~p"/signup"} class="font-semibold text-sakura hover:text-sakura-dark">
                Sign up
              </.link>
            </p>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
