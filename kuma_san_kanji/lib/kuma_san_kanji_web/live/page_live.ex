defmodule KumaSanKanjiWeb.PageLive do
  use KumaSanKanjiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Check if user is authenticated
    is_authenticated = socket.assigns[:current_user] != nil

    {:ok, assign(socket, is_authenticated: is_authenticated)}
  end

  # Template is now in page_live.html.heex
end
