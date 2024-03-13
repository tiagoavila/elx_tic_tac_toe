defmodule ElxTicTacToe.GameStarterTest do
  use ExUnit.Case
  alias ElxTicTacToe.GameStarter

  describe "create/1" do
    test "Creation of a new game" do
      data = GameStarter.create(%{player_name: "player1"})
      assert {:ok, _} = data

      {:ok, game} = data
      assert game.type == :start
      assert game.player_name == "player1"
      assert game.game_code != nil
      assert String.length(game.game_code) == 4
    end

    test "Joining an existing game" do
      data = GameStarter.create(%{player_name: "player2", game_code: "ABCD"})
      assert {:ok, _} = data

      {:ok, game} = data
      assert game.type == :join
      assert game.player_name == "player2"
      assert game.game_code == "ABCD"
    end
  end
end
