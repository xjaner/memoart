defmodule MemoartWeb.PlayLive.Show do
  use MemoartWeb, :live_view

  alias MemoartWeb.PlayView
  alias Phoenix.Socket.Broadcast

  def mount(%{"game_id" => game_id}, _session, socket) do
    game_name = "game:#{game_id}"
    if connected?(socket), do: subscribe(game_name)

    game_state = Memoart.Game.get_game_session(game_name)
    # This can cause race conditions
    player_id = "player_#{Enum.count(game_state.points) + 1}"
    game_state = Memoart.Session.add_player(game_name, player_id)

    socket = assign(socket, 
      game_name: game_name,
      player_id: player_id,
    )

    socket = set_game_state(socket, game_state)

    {:ok, socket}
  end

  def render(assigns) do
    PlayView.render("play.html", assigns)
  end

  def subscribe(game_name) do
    Phoenix.PubSub.subscribe Memoart.PubSub, game_name
  end

  def handle_event("card_click_" <> card_id, _,socket) do
    IO.puts("card_click_#{card_id}")
    %{game_name: game_name, player_id: player_id} = socket.assigns
    new_state = Memoart.Session.card_click(game_name, card_id, player_id)
    MemoartWeb.Endpoint.broadcast_from!(self(), game_name, "refresh_state", new_state)
    socket = set_game_state(socket, new_state)
    IO.puts("card_click_#{card_id} processed")
    {:noreply, socket}
  end

  def handle_info(%Broadcast{event: "refresh_state", payload: game_state}, socket) do
    IO.puts("[Player #{socket.assigns.player_id}] REFRESH STATE")
    {:noreply, set_game_state(socket, game_state)}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{reader_count: count}} = socket
      ) do
    reader_count = count + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :reader_count, reader_count)}
  end

  defp set_game_state(socket, game_state) do
    %Memoart.Game{state: state, current_player: current_player, last_card: last_card, cards: cards, points: points, error: error} = game_state
    assign(
      socket,
      state: socket,
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
