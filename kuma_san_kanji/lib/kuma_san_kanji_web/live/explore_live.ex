defmodule KumaSanKanjiWeb.ExploreLive do
  use KumaSanKanjiWeb, :live_view
  alias KumaSanKanji.Kanji.Kanji

  @impl true
  def mount(_params, _session, socket) do
    # Determine if the user is logged in
    is_authenticated = socket.assigns[:current_user] != nil

    case Kanji.count_all!() do
      total_kanji when total_kanji > 0 ->
        current_offset = 0

        case get_kanji_by_offset(current_offset) do
          {:ok, kanji} ->
            {:ok,
             assign(socket,
               kanji: kanji,
               current_offset: current_offset,
               total_kanji: total_kanji,
               is_authenticated: is_authenticated
             )}

          _ ->
            # Should not happen if count > 0, but handle defensively
            {:ok,
             assign(socket,
               kanji: nil,
               current_offset: 0,
               total_kanji: 0,
               is_authenticated: is_authenticated
             )}
        end

      _ ->
        # No kanji in the database
        {:ok,
         assign(socket,
           kanji: nil,
           current_offset: 0,
           total_kanji: 0,
           is_authenticated: is_authenticated
         )}
    end
  end

  @impl true
  def handle_event("new_kanji", _params, socket) do
    current_offset = socket.assigns.current_offset + 1
    total_kanji = socket.assigns.total_kanji

    new_offset =
      if total_kanji > 0 do
        rem(current_offset, total_kanji)
      else
        0
      end

    case get_kanji_by_offset(new_offset) do
      {:ok, kanji} ->
        {:noreply, assign(socket, kanji: kanji, current_offset: new_offset)}

      _ ->
        # Error fetching, or no kanji, keep current state or show error
        {:noreply, socket}
    end
  end

  defp get_kanji_by_offset(offset) do
    case Kanji.by_offset(offset) do
      {:ok, [kanji | _]} ->
        # Load relationships
        case Kanji.get_by_id(kanji.id, load: [:meanings, :pronunciations, :example_sentences]) do
          {:ok, [loaded_kanji]} -> {:ok, loaded_kanji}
          error -> error
        end

      {:ok, []} ->
        {:error, :no_kanji_at_offset}

      error ->
        error
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 sm:py-20 lg:px-8 xl:px-20 xl:py-24">
      <div class="mx-auto max-w-2xl">
        <h1 class="text-3xl font-display tracking-tight text-accent-blue sm:text-4xl">
          Explore Kanji <span class="text-sakura-dark">漢字</span>
        </h1>
        
        <p class="mt-3 text-lg font-katakana text-gray-700">
          Learn and discover Japanese kanji characters with Kuma-san! Click the button below to see a new kanji.
        </p>
        
        <div class="mt-6 mb-8">
          <button
            phx-click="new_kanji"
            class="btn-accent rounded-md px-3.5 py-2.5 text-sm font-katakana font-medium"
          >
            Show New Kanji
          </button>
        </div>
        
        <div
          :if={@kanji}
          class="bg-white shadow-lg rounded-lg overflow-hidden border border-accent-purple"
        >
          <div class="p-6 text-center border-b border-sakura bg-sakura-light">
            <span class="kanji-display text-8xl font-bold">{@kanji.character}</span>
          </div>
          
          <div class="p-6 bg-white text-gray-700">
            <div class="grid grid-cols-2 gap-4 mb-6">
              <div>
                <h3 class="text-sm font-semibold text-accent-blue font-display">Grade</h3>
                
                <p class="mt-1 text-lg font-katakana">{@kanji.grade || "N/A"}</p>
              </div>
              
              <div>
                <h3 class="text-sm font-semibold text-accent-blue font-display">Stroke Count</h3>
                
                <p class="mt-1 text-lg font-katakana">{@kanji.stroke_count || "N/A"}</p>
              </div>
              
              <div>
                <h3 class="text-sm font-semibold text-accent-blue font-display">JLPT Level</h3>
                
                <p class="mt-1 text-lg font-katakana">N{@kanji.jlpt_level || "N/A"}</p>
              </div>
            </div>
            
            <h3 class="text-lg font-semibold text-accent-green font-display mb-2">Meanings</h3>
            
            <ul class="mb-6 list-disc pl-6">
              <%= for meaning <- @kanji.meanings do %>
                <li class={if meaning.is_primary, do: "font-bold", else: ""}>
                  {meaning.value}
                </li>
              <% end %>
            </ul>
            
            <h3 class="text-lg font-semibold text-accent-pink font-display mb-2">Pronunciations</h3>
            
            <div class="mb-6">
              <div class="overflow-hidden bg-gray-50 rounded-md border border-sakura">
                <ul role="list" class="divide-y divide-sakura/30">
                  <%= for pronunciation <- @kanji.pronunciations do %>
                    <li class="p-4">
                      <div class="flex justify-between">
                        <span class="font-medium font-katakana">
                          {pronunciation.value}
                          <span class="ml-1 text-sm text-gray-600">({pronunciation.romaji})</span>
                        </span>
                        
                        <span class={
                          case pronunciation.type do
                            "on" ->
                              "rounded-full bg-accent-blue/10 border border-accent-blue px-2.5 py-0.5 text-xs font-medium text-accent-blue"

                            "kun" ->
                              "rounded-full bg-accent-green/10 border border-accent-green px-2.5 py-0.5 text-xs font-medium text-accent-green"

                            _ ->
                              "rounded-full bg-accent-pink/10 border border-accent-pink px-2.5 py-0.5 text-xs font-medium text-accent-pink"
                          end
                        }>
                          {pronunciation.type}
                        </span>
                      </div>
                    </li>
                  <% end %>
                </ul>
              </div>
            </div>
            
            <h3 class="text-lg font-semibold text-accent-purple font-display mb-2">
              Example Sentences
            </h3>
            
            <div class="overflow-hidden bg-gray-50 sm:rounded-md border border-accent-purple">
              <ul role="list" class="divide-y divide-accent-purple/30">
                <%= for sentence <- @kanji.example_sentences do %>
                  <li class="p-4">
                    <p class="font-medium jp-text text-gray-800">{sentence.japanese}</p>
                    
                    <p class="text-gray-600 mt-1 font-katakana">{sentence.translation}</p>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
        </div>
        
        <div
          :if={!@kanji}
          class="mt-8 bg-white shadow-lg rounded-lg overflow-hidden border border-sakura p-6"
        >
          <div class="text-center">
            <p class="text-lg text-gray-700 font-katakana">
              No kanji data available. Please add kanji to the database.
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
