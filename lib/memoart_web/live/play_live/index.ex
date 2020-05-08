defmodule MemoartWeb.PlayLive.Index do
  use MemoartWeb, :live_view

  alias MemoartWeb.PlayView

  def mount(_params, _session, socket) do
    socket = assign(socket, :game_id, "default")
    {:ok, socket}
  end

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def handle_event("change_game_id", %{"game_id" => game_id}, socket) do
    # TODO: Validate game_id value!
    {:noreply, assign(socket, :game_id, game_id)}
  end
end

