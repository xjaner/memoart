defmodule Memoart.Game do
  defstruct state: :waiting, num_players: 0, current_player: nil, last_card: nil, cards: [], points: %{}, error: nil
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
        pid
      _ ->
        new_game(game_name)
    end
    Memoart.Session.get_game_state(game_name)
  end

  def get_session_pid(game_name) do
    game_name
    |> String.to_atom()
    |> Process.whereis()
  end

  def new_game(game_name) do
    cards = get_cards()
    GenServer.start_link(Memoart.Session, %{cards: cards}, name: String.to_atom(game_name))
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
    # |> rotaten(player_num)
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

  def process_click(cards, card_id) do
    Enum.map(cards, &(flip_card(&1, card_id)))
  end
end
