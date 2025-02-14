defmodule MemoartWeb.PlayLive do
  use MemoartWeb, :live_view

  alias MemoartWeb.PlayView
  alias MemoartWeb.Presence
  alias Phoenix.Socket.Broadcast

  def mount(_params, %{"game_id" => game_id, "player_name" => player_name}, socket) do
    game_name = "game:#{String.trim(String.downcase(game_id))}"
    player_name = String.trim(player_name)
    IO.puts("Received request from player #{player_name} to join game #{game_name}.")

    if connected?(socket), do: subscribe(game_name)

    {game_state, player_id} = Memoart.Game.get_game_session(game_name, player_name)

    socket = assign(socket,
      game_name: game_name,
      player_name: player_name,
      player_id: player_id
    )

    socket = set_game_state(socket, game_state)

    socket = case player_id do
      nil ->
        assign(socket,
          error: "La partida està plena o ja ha començat!"
        )

      _ ->
        MemoartWeb.Endpoint.broadcast_from!(self(), game_name, "refresh_state", game_state)
        Presence.track( self(), game_name, player_name, %{})
        socket
    end

    {:ok, socket}
  end

  def render(assigns) do
    PlayView.render("play.html", assigns)
  end

  def subscribe(game_name) do
    Phoenix.PubSub.subscribe Memoart.PubSub, game_name
  end

  def handle_event("card_click_" <> card_id, _,socket) do
    %{game_name: game_name, player_name: player_name, player_id: player_id} = socket.assigns

    {result, new_state} = Memoart.Session.card_click(game_name, card_id, player_id)
    IO.puts("[live.card_click/before] card_click_#{card_id} by player #{player_name} in game #{game_name}: #{result} - current_player_id: #{new_state.current_player_id}")

    new_state = case result do
      :ok -> Memoart.Session.next_player(game_name)
      :no_match ->
        Process.send_after(self(), %{event: "no_match", player_id: player_id}, 2_000)
        new_state
      _ -> new_state
    end

    MemoartWeb.Endpoint.broadcast_from!(self(), game_name, "refresh_state", new_state)

    IO.puts("[live.card_click/after] card_click_#{card_id} by player #{player_name} in game #{game_name}: #{result} - current_player_id: #{new_state.current_player_id}")

    {:noreply, set_game_state(socket, new_state)}
  end

  def handle_event("start_game", _, socket) do
    %{game_name: game_name} = socket.assigns
    game_state = Memoart.Session.start_game(game_name)

    # Set initial countdown value and call :decrement every second
    {:ok, timer_ref} = :timer.send_interval(1_000, :decrement)
    socket = assign(socket, :timer_ref, timer_ref)

    MemoartWeb.Endpoint.broadcast_from!(self(), game_name, "refresh_state", game_state)

    {:noreply, set_game_state(socket, game_state)}
  end

  def handle_info(%Broadcast{event: "refresh_state", payload: game_state}, socket) do
    {:noreply, set_game_state(socket, game_state)}
  end

  def handle_info(:decrement, socket) do
    %{game_name: game_name} = socket.assigns
    game_state = Memoart.Session.decrement_countdown(game_name)

    MemoartWeb.Endpoint.broadcast_from!(self(), game_name, "refresh_state", game_state)

    if game_state.countdown <= 0 do
      tref = socket.assigns[:timer_ref]
      :timer.cancel(tref)
    end

    {:noreply, set_game_state(socket, game_state)}
  end

  def handle_info(%{event: "no_match", player_id: player_id}, socket) do
    %{game_name: game_name} = socket.assigns

    new_state = Memoart.Session.no_match(game_name, player_id)

    if new_state.state == :finished do
      Memoart.Session.kill_game(game_name)
    end

    MemoartWeb.Endpoint.broadcast_from!(self(), game_name, "refresh_state", new_state)

    {:noreply, set_game_state(socket, new_state)}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket
      ) do
    # TODO: Handle users that leave
    {:noreply, socket}
  end

  defp set_game_state(socket, game_state) do
    %Memoart.Game{state: state, current_player_id: current_player_id, current_round: current_round, last_card_id: last_card_id, points: points, error: error, countdown: countdown, round_points: round_points, round_message: round_message, players: players, active_players: active_players, flipped_cards: flipped_cards} = game_state
    cards = Memoart.Game.rotate_cards(game_state, socket.assigns.player_id)
    cards = Memoart.Game.show_first_line_if_needed(state, cards, socket.assigns.player_id)
    assign(
      socket,
      state: state,
      current_player: Enum.at(game_state.players, current_player_id || 0),  # I need to pass a default value in case current_player_id is nil
      current_player_id: current_player_id,
      current_round: current_round,
      last_card_id: last_card_id,
      cards: cards,
      points: points,
      players: players,
      error: error,
      countdown: countdown,
      round_points: round_points,
      round_message: round_message,
      active_players: active_players,
      flipped_cards: flipped_cards
    )
  end

  def error(%{error: error}) do
    error
  end
end
