defmodule Memoart.Session do
  use GenServer

  @impl GenServer
  def init(%{cards: cards}) do
    {:ok, %Memoart.Game{cards: cards, num_players: 1, points: %{player0: 0}}}
  end

  def get_game_state(game_name) do
    game_name
    |> String.to_atom()
    |> Process.whereis()
    |> GenServer.call({:get_state})
  end

  def add_player(game_name) do
    game_name
    |> String.to_atom()
    |> Process.whereis()
    |> GenServer.call({:add_player})
  end

  @impl GenServer
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:add_player}, _from, state) do
    new_state = Map.update!(state, :num_players, &(&1 + 1))
    {:reply, new_state, new_state}
  end
end
