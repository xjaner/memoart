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

  def kill_game(game_name) do
    game_name
    |> String.to_atom()
    |> Process.whereis()
    |> Process.exit(:kill)
  end

  def card_click(game_name, card_id, player_id) do
    game_name
    |> call_function({:card_click, card_id, player_id})
  end

  def get_game_state(game_name) do
    game_name
    |> call_function({:get_state})
  end

  def add_player(game_name, player_name) do
    game_name
    |> call_function({:add_player, player_name})
  end
 
  def no_match(game_name, player_id) do
    game_name
    |> call_function({:no_match, player_id})
  end
 
  def next_player(game_name) do
    game_name
    |> call_function({:next_player})
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
  def handle_call({:add_player, player_name}, _from, state) do
    {new_state, player_id} = Memoart.Game.add_player(state, player_name)
    {:reply, {new_state, player_id}, new_state}
  end

  @impl GenServer
  def handle_call({:no_match, player_id}, _from, state) do
    new_state = Memoart.Game.no_match(state, player_id)
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:next_player}, _from, state) do
    new_state = Memoart.Game.next_player(state)
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:card_click, card_id, player_id}, _from, state) do
    {result, new_state} = state
    |> Memoart.Game.card_click(card_id, player_id)
    {:reply, {result, new_state}, new_state}
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
