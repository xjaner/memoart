defmodule MemoartWeb.PlayLive.Show do
  use MemoartWeb, :live_view

  alias MemoartWeb.PlayView

  def mount(%{"game_id" => game_id}, _session, socket) do
    game = "game:#{game_id}"
    game_state = Memoart.Game.get_game_session(game)
    IO.inspect(game_state)
    player_num = game_state.num_players
    socket = assign(socket, :player_num, player_num)

    socket = set_game_state(socket, game_state)

    # MemoartWeb.Endpoint.subscribe(game)
    # MemoartWeb.Presence.track(
    #   self(),
    #   game,
    #   socket.id,
    #   %{}
    # )
    # socket = assign(socket, :reader_count, num_players)

    # socket = case Memoart.Game.new_game(player_num) do
    #   {:ok, cards} -> 
    #     socket
    #     |> assign(:cards, cards)
    #     |> put_flash(:info, "Benvingut a la partida!")

    #   {:error, cards} -> 
    #     socket
    #     |> set_error("La partida està plena")
    #     |> assign(:cards, cards)
    # end
    # IO.puts("Player num: #{player_num} - error(assigns): #{IO.inspect(error(socket.assigns))}")
    {:ok, socket}
  end

  def render(assigns) do
    PlayView.render("play.html", assigns)
  end

  def handle_event("card_click_" <> card_id, _,socket) do
    IO.puts("card_click_#{card_id}")
    cards = socket.assigns.cards
            |> Memoart.Game.process_click(String.to_integer(card_id))
    socket = assign(socket, :cards, cards)
    IO.puts("card_click_#{card_id} processed")
    {:noreply, socket}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{reader_count: count}} = socket
      ) do
    reader_count = count + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :reader_count, reader_count)}
  end

  defp set_game_state(socket, game_state) do
    %Memoart.Game{state: state, num_players: num_players, current_player: current_player, last_card: last_card, cards: cards, points: points, error: error} = game_state
    assign(
      socket,
      state: socket,
      num_players: num_players,
      current_player: current_player,
      last_card: last_card,
      cards: cards,
      points: points,
      error: error
    )
  end

  defp set_error(socket, msg) do
    assign(socket, :error, msg)
  end

  def error(%{error: error}) do
    error
  end

  def splash(assigns) do
    cond do
      error(assigns) ->
        true
      true ->
        false
    end
  end
end
