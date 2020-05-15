defmodule Memoart.Game do
  defstruct game_name: nil, state: :waiting, current_player: nil, last_card: nil, cards: [], points: %{}, error: nil, rotation: %{}
  @num_cards 25
  @max_players 4

  @items [
    "canvas",
    "palette",
    "roller",
    "splash",
    "star"
  ]

  @paintings [
    "gernika",
    "kandinsky",
    "monet",
    "rothko",
    "vangogh"
  ]

  @seat_rotations %{
      0 => 0,
      1 => 2,
      2 => 1,
      3 => 3
  }

  def get_game_session(game_name, player_id) do
    case get_session_pid(game_name) do
      pid when is_pid(pid) ->
        IO.puts("Game #{game_name} already exists")
        pid
      _ ->
        IO.puts("Creating game #{game_name}")
        new_game(game_name)
    end
    Memoart.Session.add_player(game_name, player_id)
  end

  def add_player(game_state, player_id) do
    case game_state.points do
      %{^player_id => _} -> game_state
      _ -> add_player_to_points_and_rotation(game_state, player_id)
    end
  end

  defp add_player_to_points_and_rotation(game_state, player_id) do
    game_state
    |> add_player_to_points(player_id)
    |> add_player_to_rotation(player_id)
end

  defp add_player_to_points(game_state, player_id) do
    %{game_state | points: Map.put_new(game_state.points, player_id, 0)}
  end

  defp add_player_to_rotation(game_state, player_id) do
    %{game_state | rotation: Map.put_new(game_state.rotation, player_id, @seat_rotations[Enum.count(game_state.rotation)])}
  end

  def get_session_pid(game_name) do
    game_name
    |> String.to_atom()
    |> Process.whereis()
  end

  def new_game(game_name) do
    cards = get_cards()
    GenServer.start_link(Memoart.Session, %{cards: cards, game_name: game_name}, name: String.to_atom(game_name))
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

  def card_click(%{cards: cards} = game_state, card_id, player_id) do
    # TODO: Check id player_id is the active one
    cards
    |> Enum.map(&(flip_card(&1, String.to_integer(card_id))))
    |> process_matching(game_state)
  end

  def rotate_cards(cards, rotations) do
    rotaten(cards, rotations)
  end
end
