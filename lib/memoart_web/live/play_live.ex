defmodule MemoartWeb.PlayLive do
  use MemoartWeb, :live_view

  alias MemoartWeb.PlayView

  def mount(_params, _session, socket) do
    socket = assign(socket, :card_flip_1, "")
    socket = assign(socket, :card_flip_2, "")
    socket = assign(socket, :card_back_1, "kandinsky")
    socket = assign(socket, :card_back_2, "gernika")
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

  def handle_event("card_click_" <> card_id, _, socket) do
    flip_atom = String.to_atom("card_flip_#{card_id}")
    new_class = case socket.assigns[flip_atom] do
      "" -> "hover"
      _ -> ""
    end
    IO.puts("A#{card_id}")
    socket = assign(socket, flip_atom, new_class)
    {:noreply, socket}
  end
end
