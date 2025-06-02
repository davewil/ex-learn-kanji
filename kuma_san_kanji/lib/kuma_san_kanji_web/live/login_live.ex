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
        <h1 class="text-3xl font-bold tracking-tight text-zinc-900 sm:text-4xl">
          Log In
        </h1>
        <p class="mt-3 text-lg text-zinc-600">
          Welcome back! Log in to continue your kanji learning journey.
        </p>
        
        <.form
          for={@form}
          action={~p"/login"}
          method="post"
          class="mt-8 space-y-6"
        >
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
                value={@form[:email].value}
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                placeholder="you@example.com"
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
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
              />
            </div>
          </div>
          
          <div>
            <button
              type="submit"
              class="w-full rounded-md bg-blue-600 py-2.5 px-3.5 text-sm font-medium text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              Log in
            </button>
          </div>
          
          <div class="text-center text-sm">
            <p class="text-gray-600">
              Don't have an account?
              <.link navigate={~p"/signup"} class="font-semibold text-blue-600 hover:text-blue-500">
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
