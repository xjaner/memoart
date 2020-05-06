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

  def new_game do
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
