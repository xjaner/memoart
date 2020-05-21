defmodule MemoartWeb.PageController do
  use MemoartWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", token: get_csrf_token())
  end

  def new(conn, %{"game_id" => game_id, "player_name" => player_name} = params) do
    Phoenix.LiveView.Controller.live_render(conn, MemoartWeb.PlayLive, session: %{
      "game_id" => game_id,
      "player_name" => player_name
    })
  end
end
