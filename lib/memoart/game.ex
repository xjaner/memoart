defmodule Memoart.Game do
  defstruct game_name: nil, state: :waiting, current_player: nil, last_card: nil, cards: [], points: %{}, error: nil
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

  def get_game_session(game_name) do
    case get_session_pid(game_name) do
      pid when is_pid(pid) ->
        IO.puts("Game #{game_name} already exists")
        pid
      _ ->
        IO.puts("Creating game #{game_name}")
        new_game(game_name)
    end
    Memoart.Session.get_game_state(game_name)
  end

  def add_player(game_state, player_id) do
    case game_state.points do
      %{^player_id => _} -> game_state.points
      _ -> Map.put_new(game_state.points, player_id, 0)
    end
    |> update_points(game_state)
  end

  defp update_points(points, game_state) do
    %{game_state | points: points}
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
    # We'll rotate at the live view
    # |> rotaten(player_id)
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
end
