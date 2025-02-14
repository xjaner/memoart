defmodule Memoart.Game do
  defstruct game_name: nil, state: :waiting, current_round: 0, current_player_id: nil, last_card_id: nil, cards: [], points: %{}, error: nil, rotation: %{}, players: [], countdown: nil, active_players: [], round_points: nil, last_player_id: nil, round_message: nil, flipped_cards: []

  # States:
  # - waiting
  # - showing_first_line
  # - round_1
  # - round_2
  # - round_3
  # - round_4
  # - round_5
  # - round_6
  # - round_7
  # - finished

  @num_cards 25
  @max_players 4
  @countdown_seconds 15
  @finish_round 8


  @items [
    "brush",
    "canvas",
    "palette",
    "pencil",
    "roller"
  ]

  @paintings [
    "gernika",
    "kandinsky",
    "monet",
    "rothko",
    "vangogh"
  ]

  @seat_rotation %{
      0 => 0,
      1 => 2,
      2 => 1,
      3 => 3
  }

  @flipped_cards_per_player %{
    0 => [1, 2, 3],
    1 => [23, 22, 21],
    2 => [15, 10, 5],
    3 => [9, 14, 19]
  }

  @points_per_round %{
    1 => 1,
    2 => 1,
    3 => 2,
    4 => 2,
    5 => 2,
    6 => 3,
    7 => 4,
  }

  defp item_pos([], _) do
    nil
  end

  defp item_pos([head | tail], key) do
    case head do
      {^key, idx} -> idx
      _ -> item_pos(tail, key)
    end
  end

  # TODO: Make a get_item_pos! variant
  def get_item_pos(l, item) do
    item_pos(Enum.with_index(l), item)
  end

  def get_game_session(game_name, player_name) do
    case get_session_pid(game_name) do
      pid when is_pid(pid) ->
        IO.puts("Game #{game_name} already exists")
        pid
      _ ->
        IO.puts("Creating game #{game_name}")
        new_game(game_name)
    end
    Memoart.Session.add_player(game_name, player_name)
  end

  def add_player(game_state, player_name) do
    case get_item_pos(game_state.players, player_name) do
      index when is_integer(index) -> {game_state, index}
      _ ->
        cond do
          Enum.count(game_state.points) >= @max_players ->
            {game_state, nil}
          true ->
            add_player_to_state(game_state, player_name)
        end
    end
  end

  defp add_player_to_state(game_state, player_name) do
    player_id = Enum.count(game_state.players)
    game_state = %{game_state | 
      points: Map.put_new(game_state.points, Enum.count(game_state.players), 0),
      rotation: Map.put_new(game_state.rotation, player_id, @seat_rotation[Enum.count(game_state.rotation)]),
      players: game_state.players ++ [player_name]
    }
    {game_state, player_id}
  end

  def get_session_pid(game_name) do
    game_name
    |> String.to_atom()
    |> Process.whereis()
  end

  def new_game(game_name) do
    cards = get_cards()
    IO.puts("[new_game] start_link from #{inspect(self())}")
    GenServer.start_link(Memoart.Session, %{cards: cards, game_name: game_name, countdown: @countdown_seconds}, name: String.to_atom(game_name))
  end

  defp get_cards() do
    pairs = get_pairs()
    Enum.map(1..@num_cards, fn n ->
      pair = Enum.at(pairs, n - 1)
      %Memoart.Card{
        id: n - 1,
        item: pair.item,
        painting: pair.painting
      }
    end)
  end

  defp get_pairs do
    for painting <- @paintings, item <- @items do
      %{
        painting: painting,
        item: item
      }
    end
    |> Enum.shuffle()
  end

  defp rotate(l) do
    l
    |> Enum.chunk_every(5)
    |> Enum.reverse()
    |> List.zip()
    |> Enum.map(&(Tuple.to_list(&1)))
    |> List.flatten
  end

  defp rotaten(l, 0) do
    l
  end

  defp rotaten(l, n) do
    rotaten(rotate(l), n - 1)
  end


  defp flip_flipped(card) do
    case card.flipped do
      "" -> %{card | flipped: "hover"}
      _ -> %{card | flipped: ""}
    end
  end

  defp flip_card(card, card_ids) when is_list(card_ids) do
    cond do
      card.id in card_ids ->
        flip_flipped(card)
      true -> card
    end
  end

  defp flip_card(card, card_id) do
    cond do
      card.id == card_id ->
        flip_flipped(card)
      true -> card
    end
  end

  defp process_matching(cards, game_state) do
      %{game_state | cards: cards}
  end

  def card_click(%{cards: cards, current_player_id: current_player_id} = game_state, card_id, player_id) do
    card_id_int = String.to_integer(card_id)
    # IO.puts("[Game.card_click] current_player_id: #{current_player_id} - player_id: #{player_id} - card_id: #{card_id}")
    IO.puts("[game.card_click/before] active_players: #{inspect(game_state.active_players)} - player_id: #{player_id} - current_player_id: #{game_state.current_player_id}")
    {result, game_state} = case current_player_id do
      ^player_id ->
        cards
        |> Enum.map(&(flip_card(&1, card_id_int)))
        |> process_matching(game_state)
        |> validate_card(card_id_int)

      _ -> {:wrong_player, game_state}
    end
    IO.puts("[game.card_click/after] active_players: #{inspect(game_state.active_players)} - player_id: #{player_id} - current_player_id: #{game_state.current_player_id}")
    {result, game_state}
  end

  defp validate_card(game_state, card_id) do
    {result, game_state} = case game_state.last_card_id do
      nil -> {:ok, game_state}
      last_card_id -> validate_two_cards(game_state, last_card_id, card_id)
    end
    game_state = %{game_state | last_card_id: card_id, flipped_cards: [card_id | game_state.flipped_cards]}
    {result, game_state}
  end

  defp validate_two_cards(game_state, last_card_id, current_card_id) do
    last = Enum.at(game_state.cards, last_card_id)
    current = Enum.at(game_state.cards, current_card_id)
    cond do
      last.item == current.item or last.painting == current.painting ->
        {:ok, game_state}

      true ->
        game_state = %{game_state | current_player_id: nil, round_message: "La carta no és vàlida!"}
        {:no_match, game_state}
    end
  end

  def rotate_cards(game_state, player_id) do
    rotation = case Map.fetch(game_state.rotation, player_id) do
      {:ok, rotation} -> rotation
      :error -> 0
    end
    rotaten(game_state.cards, rotation)
  end

  def start_game(game_state) do
    new_state = %{game_state | state: :showing_first_line}
    new_state
  end

  def decrement_countdown(game_state) do
    new_state = Map.update!(game_state, :countdown, &(&1 - 1))

    cond do
      new_state.countdown <= 0 -> end_round(new_state, new_state.current_round)
      true -> new_state
    end
  end

  defp end_round(game_state, round_id) do
    # Set current_player
    # Set current_round
    next_round = String.to_atom("round_#{round_id + 1}")
    round_points = Map.get(@points_per_round, round_id + 1)
    %{game_state |
      state: next_round,
      current_player_id: 0,
      round_points: round_points,
      current_round: 1,
      active_players: Enum.to_list(0..Enum.count(game_state.players)-1),
      flipped_cards: []
    }
  end

  def show_first_line_if_needed(state, cards, player_id) do
    case state do
      :showing_first_line ->
        cards
        |> Enum.map(&(flip_card(&1, Map.get(@flipped_cards_per_player, player_id))))
      _ ->
        cards
    end
  end

  def next_player(game_state) do
    IO.puts("[next_player/before] active_players: #{inspect(game_state.active_players)} - current_player_id: #{game_state.current_player_id}")
    game_state = %{game_state | current_player_id: Enum.at(game_state.active_players, rem(get_item_pos(game_state.active_players, game_state.current_player_id) + 1, Enum.count(game_state.active_players)))}
    IO.puts("[next_player/after] active_players: #{inspect(game_state.active_players)} - current_player_id: #{game_state.current_player_id}")
    game_state
  end

  def get_winner_id(state) do
    {winner_id, _} = state.points
    |> Enum.to_list
    |> Enum.sort_by(&(elem(&1, 1)), :desc)
    |> Enum.at(0)
    winner_id
  end

  def finish(state) do
    # TODO: Kill game_name process
    winner_id = get_winner_id(state)
    final_message = "Final de la partida! El guanyador és #{Enum.at(state.players, winner_id)}"
    %{state | error: final_message, state: :finished}
  end

  def reset_board(state) do
    %{state |
      cards: Enum.map(state.cards, fn card -> %{card | flipped: ""} end),
      flipped_cards: []
    }
  end

  def add_points(state, last_player_id, winner_id) do
    IO.puts("add_points(#{last_player_id}, #{winner_id}) - current_round: #{state.current_round}")
    state = %{state | points: Map.update!(state.points, winner_id, &(&1 + @points_per_round[state.current_round]))}
    next_round_id = state.current_round + 1
    active_players = Enum.to_list(0..Enum.count(state.players) - 1)
    next_player = Enum.random(active_players -- [winner_id])

    case next_round_id do
      @finish_round ->
        finish(state)
      _ ->
        %{state |
          state: String.to_atom("round_#{next_round_id}"),
          current_round: next_round_id,
          round_points: @points_per_round[next_round_id],
          active_players: active_players,
          current_player_id: next_player,
          round_message: nil,
          last_card_id: nil
        }
        |> reset_board()
    end
  end

  def next_round(state, player_id) do
    IO.puts("active_players: #{inspect(state.active_players)} - player_id: #{player_id}")
    [winner_id] = state.active_players -- [player_id]
    state
    |> add_points(player_id, winner_id)
  end

  defp remove_player(game_state, player_id) do
    IO.puts("[remove_player/before] active_players: #{inspect(game_state.active_players)} - player_id: #{player_id} - current_player_id: #{game_state.current_player_id}")
    dead_player_pos = get_item_pos(game_state.active_players, player_id)
    game_state = %{game_state |
      active_players: game_state.active_players -- [player_id],
      round_message: nil
    }
    game_state = %{game_state | current_player_id: Enum.at(game_state.active_players, rem(dead_player_pos, Enum.count(game_state.active_players)))}
    IO.puts("[remove_player/after] active_players: #{inspect(game_state.active_players)} - player_id: #{player_id} - current_player_id: #{game_state.current_player_id}")
    game_state
  end

  def no_match(state, player_id) do
    state = cond do
      Enum.count(state.active_players) > 2 ->
        state
        |> remove_player(player_id)
      true ->
        state
        |> next_round(player_id)
    end
    IO.puts("[no_match/after] active_players: #{inspect(state.active_players)} - player_id: #{player_id} - current_player_id: #{state.current_player_id}")
    state
  end
end
