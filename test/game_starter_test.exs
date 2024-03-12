defmodule ElxTicTacToe.GameStarterTest do
  use ExUnit.Case
  alias ElxTicTacToe.GameStarter

  test "Creation of a new game" do
    {:ok, data} = GameStarter.create(%{player_name: "player1"})
    assert data.type == :start
    assert data.player_name == "player1"
    assert data.game_code != nil
    assert String.length(data.game_code) == 4
  end
end
