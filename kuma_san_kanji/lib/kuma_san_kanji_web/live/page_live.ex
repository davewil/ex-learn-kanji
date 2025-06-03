defmodule KumaSanKanjiWeb.PageLive do
  use KumaSanKanjiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Check if user is authenticated
    is_authenticated = socket.assigns[:current_user] != nil

    {:ok, assign(socket, is_authenticated: is_authenticated)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 sm:py-28 lg:px-8 xl:px-28 xl:py-32">
      <div class="mx-auto max-w-xl lg:mx-0">
        <h1 class="text-[2rem] mt-4 font-display tracking-tight text-accent-blue sm:text-5xl">
          Kuma-san Kanji <span class="text-sakura-dark">漢字</span>
        </h1>
        <p class="mt-4 text-lg font-katakana text-gray-700">
          Welcome <%= if @is_authenticated, do: "back", else: "" %> to Kuma-san Kanji, your friendly bear guide to learning Japanese Kanji characters!
        </p>
        <div class="mt-10 flex items-center gap-x-6">
          <.link
            navigate={~p"/explore"}
            class="btn-accent rounded-md px-3.5 py-2.5 text-sm font-katakana font-medium"
          >
            Explore Kanji
          </.link>
          <%= if @is_authenticated do %>
            <p class="text-sm font-katakana text-gray-600">
              You're logged in as <span class="font-bold text-accent-blue"><%= @current_user.username %></span>
            </p>
          <% else %>
            <.link
              navigate={~p"/signup"}
              class="btn-sakura rounded-md px-3.5 py-2.5 text-sm font-katakana font-medium"
            >
              Sign Up
            </.link>
            <.link
              navigate={~p"/login"}
              class="rounded-md border border-accent-blue px-3.5 py-2.5 text-sm font-katakana font-medium text-accent-blue shadow-sm hover:bg-gray-50"
            >
              Log In
            </.link>
          <% end %>
        </div>

        <div class="mt-10">
          <h2 class="text-2xl font-katakana tracking-tight text-accent-blue">
            How it works
          </h2>

          <div class="mt-4 rounded-lg border border-sakura bg-sakura-light/20 p-6">
            <ol class="list-decimal pl-6 space-y-2 font-katakana text-gray-700">
              <li>Explore new kanji characters daily.</li>
              <li>Learn meanings, readings, and stroke counts.</li>
              <li>Practice with example sentences.</li>
              <li>Sign up to track your progress.</li>
            </ol>

            <div class="mt-6 flex justify-center">
              <img src="/images/bear-reading.svg" alt="Kuma-san reading" class="w-64 h-64" />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
