defmodule KumaSanKanjiWeb.Components.Navigation do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: KumaSanKanjiWeb.Endpoint, router: KumaSanKanjiWeb.Router
  alias Phoenix.LiveView.JS

  def navbar(assigns) do
    ~H"""
    <header class="bg-white shadow-lg border-b-2 border-sakura" id="main-nav" phx-hook="MobileMenu">
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 items-center justify-between">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <.link navigate={~p"/"} class="text-2xl font-display text-accent-blue">
                Kuma-san Kanji <span class="text-sakura-dark">漢字</span>
              </.link>
            </div>
            <div class="hidden md:ml-6 md:flex md:space-x-8">
              <.link
                navigate={~p"/"}
                class="inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-katakana font-medium text-sakura-light hover:border-sakura hover:text-sakura"
              >
                Home
              </.link>
              <.link
                navigate={~p"/explore"}
                class="inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-katakana font-medium text-sakura-light hover:border-sakura hover:text-sakura"
              >
                Explore
              </.link>
            </div>
          </div>
          <div class="hidden md:ml-6 md:flex md:items-center">
            <div class="flex items-center space-x-4">
              <%= if @current_user do %>
                <div class="text-sm font-katakana text-sakura-light">
                  Hello, <span class="font-bold text-sakura"><%= @current_user.username %></span>
                </div>                <.link
                  href={~p"/logout"}
                  method="delete"
                  class="rounded-md bg-white px-3 py-2 text-sm font-katakana font-semibold text-accent-blue border border-accent-blue hover:bg-gray-50"
                >
                  Log out
                </.link>
              <% else %>
                <.link
                  navigate={~p"/signup"}
                  class="rounded-md bg-sakura px-3 py-2 text-sm font-katakana font-semibold text-white hover:bg-sakura-dark"
                >
                  Sign up
                </.link>                <.link
                  navigate={~p"/login"}
                  class="rounded-md bg-white px-3 py-2 text-sm font-katakana font-semibold text-accent-blue border border-accent-blue hover:bg-gray-50"
                >
                  Log in
                </.link>
              <% end %>
            </div>
          </div>
          <div class="-mr-2 flex items-center md:hidden">
            <!-- Mobile menu button -->
            <button
              phx-click={JS.dispatch("toggle-mobile-menu")}
              type="button"
              class="relative inline-flex items-center justify-center rounded-md bg-white p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
              aria-expanded="false"
            >
              <span class="absolute -inset-0.5"></span>
              <span class="sr-only">Open main menu</span>
              <svg
                class="block h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Mobile menu, show/hide based on menu state. -->
      <div class="md:hidden hidden" id="mobile-menu">
        <div class="space-y-1 pb-3 pt-2">
          <.link
            navigate={~p"/"}
            class="block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-medium text-gray-600 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-800"
          >
            Home
          </.link>
          <.link
            navigate={~p"/explore"}
            class="block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-medium text-gray-600 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-800"
          >
            Explore
          </.link>
        </div>
        <div class="border-t border-gray-200 pb-3 pt-4">
          <%= if @current_user do %>
            <div class="flex items-center px-4">
              <div class="ml-3">
                <div class="text-base font-medium text-gray-800"><%= @current_user.username %></div>
                <div class="text-sm font-medium text-gray-500"><%= @current_user.email %></div>
              </div>
            </div>
            <div class="mt-3 space-y-1">
              <.link
                href={~p"/logout"}
                method="delete"
                class="block px-4 py-2 text-base font-medium text-gray-500 hover:bg-gray-100 hover:text-gray-800"
              >
                Log out
              </.link>
            </div>
          <% else %>
            <div class="mt-3 space-y-1 px-2">
              <.link
                navigate={~p"/signup"}
                class="block rounded-md px-3 py-2 text-base font-medium text-gray-500 hover:bg-gray-50 hover:text-gray-900"
              >
                Sign up
              </.link>
              <.link
                navigate={~p"/login"}
                class="block rounded-md px-3 py-2 text-base font-medium text-gray-500 hover:bg-gray-50 hover:text-gray-900"
              >
                Log in
              </.link>
            </div>
          <% end %>
        </div>
      </div>
    </header>
    """
  end
end
