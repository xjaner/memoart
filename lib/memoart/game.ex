defmodule Memoart.Game do
  @num_cards 25

  @paintings [
    "gernika",
    "kandinsky",
    "monet",
    "rothko",
    "vangogh"
  ]

  def new_game do
    paintings = get_paintings()
    Enum.map(1..@num_cards, fn n -> %Memoart.Card{id: n - 1, painting: Enum.at(paintings, n)} end)
  end

  defp replicate(l, n) do
    for _ <- 1..n, do: l
  end

  def get_paintings do
    @paintings
    |> replicate(5)
    |> List.flatten()
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
