defmodule Memoart.GameTest do
  use ExUnit.Case, async: true

  alias Memoart.Game

  test "get_item_pos with an empty list" do
    assert Game.get_item_pos([], "a") == nil
  end

  test "get_item_pos with a single-element list" do
    assert Game.get_item_pos(["a"], "a") == 0
  end

  test "get_item_pos with a single-element list that doesn't match" do
    assert Game.get_item_pos(["b"], "a") == nil
  end

  test "get_item_pos with multiple elements and item at the beginnig" do
    assert Game.get_item_pos(["a", "b", "c", "d"], "a") == 0
  end

  test "get_item_pos with multiple elements and item in the middle" do
    assert Game.get_item_pos(["b", "c", "a", "d", "e"], "a") == 2
  end

  test "get_item_pos with multiple elements and item at the end" do
    assert Game.get_item_pos(["b", "c", "d", "e", "a"], "a") == 4
  end
end
