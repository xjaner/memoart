defmodule MemoartWeb.PlayLive.Show do
  use MemoartWeb, :live_view

  alias MemoartWeb.PlayView

  def mount(params, _session, socket) do
    IO.inspect(params)
    game = "game:joc1"
    initial_count = MemoartWeb.Presence.list(game) |> map_size
    MemoartWeb.Endpoint.subscribe(game)

    MemoartWeb.Presence.track(
      self(),
      game,
      socket.id,
      %{}
    )
    socket = assign(socket, :reader_count, initial_count)

    cards = Memoart.Game.new_game()
    socket = assign(socket, :cards, cards)
    {:ok, socket}
  end

  def render(assigns) do
    PlayView.render("play.html", assigns)
  end

  def handle_event("a2", _, socket) do
    new_class = case socket.assigns.a2flip do
      "" -> "hover"
      _ -> ""
    end
    IO.puts("A2 - a2flip:#{socket.assigns.a2flip} --> #{new_class}")
    socket = assign(socket, :a2flip, new_class)
    {:noreply, socket}
  end

  def handle_event("card_click_" <> card_id, _,socket) do
    IO.puts("card_click")
    IO.inspect(card_id)
    cards = socket.assigns.cards
            |> Memoart.Game.process_click(String.to_integer(card_id))
    socket = assign(socket, :cards, cards)
    {:noreply, socket}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{reader_count: count}} = socket
      ) do
    reader_count = count + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :reader_count, reader_count)}
  end
end
