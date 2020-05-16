defmodule Memoart.Session do
  use GenServer

  @impl GenServer
  def init(%{cards: cards, game_name: game_name, countdown: countdown}) do
    {:ok, %Memoart.Game{cards: cards, game_name: game_name, countdown: countdown}}
  end

  defp call_function(game_name, args) do
    game_name
    |> String.to_atom()
    |> Process.whereis()
    |> GenServer.call(args)
  end

  def card_click(game_name, card_id, player_id) do
    game_name
    |> call_function({:card_click, card_id, player_id})
  end

  def get_game_state(game_name) do
    game_name
    |> call_function({:get_state})
  end

  def add_player(game_name, player_id) do
    game_name
    |> call_function({:add_player, player_id})
  end

  def start_game(game_name) do
    game_name
    |> call_function({:start_game})
  end

  def decrement_countdown(game_name) do
    game_name
    |> call_function({:decrement_countdown})
  end

  @impl GenServer
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:add_player, player_id}, _from, state) do
    new_state = Memoart.Game.add_player(state, player_id)
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:card_click, card_id, player_id}, _from, state) do
    new_state = Memoart.Game.card_click(state, card_id, player_id)
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:start_game}, _from, state) do
    new_state = Memoart.Game.start_game(state)
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:decrement_countdown}, _from, state) do
    new_state = Memoart.Game.decrement_countdown(state)
    {:reply, new_state, new_state}
  end
end
