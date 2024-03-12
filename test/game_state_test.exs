defmodule ElxTicTacToe.GameStateTest do
  use ExUnit.Case
  alias ElxTicTacToe.GameState

  describe "new/2" do
    test "initializes a game with the given code and player1" do
      code = "game123"
      player1 = "player1"
      game_state = GameState.new(code, player1)

      assert game_state.code == code
      assert game_state.player1 == player1
      assert game_state.player2 == nil
      assert game_state.current_player == nil
      assert game_state.status == :not_started
    end
  end

  describe "join/2" do
    test "returns an error when trying to join a game without an initial player" do
      game_state = %GameState{}
      {:error, _message} = GameState.join(game_state, "player2")
    end

    test "returns an error when the game already has two players" do
      game_state = %GameState{player1: "player1", player2: "player2"}
      {:error, _message} = GameState.join(game_state, "player3")
    end

    test "updates the game state when a second player joins successfully" do
      game_state = GameState.new("game123", "player1")
      updated_game_state = GameState.join(game_state, "player2")

      assert updated_game_state.player2 == "player2"
      assert updated_game_state.current_player == "player1"
      assert updated_game_state.status == :in_progress
    end
  end
end
