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
end
