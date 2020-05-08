defmodule Memoart.Game do
  @num_cards 25

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

  # def new_game(player_num) when player_num > 2 do
  #   {:error, :full_game}
  # end

  def new_game(player_num) do
    pairs = get_pairs()
    cards = Enum.map(1..@num_cards, fn n -> 
      pair = Enum.at(pairs, n - 1)
      %Memoart.Card{
        id: n - 1, 
        item: pair.item,
        painting: pair.painting
      } 
    end)
    |> rotaten(player_num)
    cond do
      player_num > 1 ->
        {:error, cards}
      true ->
        {:ok, cards}
    end
  end

  def get_pairs do
    for painting <- @paintings, item <- @items do
      %{
        painting: painting,
        item: item
      }
    end
    |> Enum.shuffle()
  end

  def rotate(l) do
    l
    |> Enum.chunk_every(5)
    |> Enum.reverse()
    |> List.zip()
    |> Enum.map(&(Tuple.to_list(&1)))
    |> List.flatten
  end

  def rotaten(l, 0) do
    l
  end

  def rotaten(l, n) do
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
