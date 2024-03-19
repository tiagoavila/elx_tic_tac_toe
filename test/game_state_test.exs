defmodule ElxTicTacToe.GameStateTest do
  @moduledoc """
  This module is responsible for testing the ElxTicTacToe.GameState module.
  """

  use ExUnit.Case
  alias ElxTicTacToe.{GameState, Player}

  setup do
    {:ok, game_state: %GameState{
      code: "ABCD",
      player1: %{id: "player1", name: "player1", letter: :X},
      player2: %{id: "player2", name: "player2", letter: :O},
      active_player: "player1",
      status: :in_progress
    }}
  end

  describe "new/2" do
    test "initializes a game with the given code and player1" do
      code = "game123"
      player1 = %Player{name: "player1"}
      game_state = GameState.new(code, player1)

      assert game_state.code == code
      assert game_state.player1.name == "player1"
      assert game_state.player2 == nil
      assert game_state.active_player == nil
      assert game_state.status == :not_started
    end
  end

  describe "join/2" do
    test "returns an error when trying to join a game without an initial player" do
      game_state = %GameState{}
      {:error, _message} = GameState.join(game_state, %Player{name: "player2"})
    end

    test "returns an error when the game already has two players" do
      game_state = %GameState{player1: %Player{name: "player1"}, player2: %Player{name: "player2"}}
      {:error, _message} = GameState.join(game_state, %Player{name: "player3"})
    end

    test "updates the game state when a second player joins successfully" do
      game_state = GameState.new("game123", %Player{name: "player1"})
      updated_game_state = GameState.join(game_state, %Player{name: "player2"})

      assert updated_game_state.player2.name == "player2"
      # assert updated_game_state.active_player == "player1"
      assert updated_game_state.status == :in_progress
    end
  end

  describe "move/3" do
    test "makes a valid move", %{game_state: state} do
      square = 1
      game_state = GameState.move(state, "player1", square)
      assert game_state.board[square] == "X"
      assert game_state.active_player == "player2"

      game_state = GameState.move(game_state, "player2", 2)
      assert game_state.board[2] == "O"
      assert game_state.active_player == "player1"
    end

    test "returns error when the square is already taken", %{game_state: state} do
      square = 1
      game_state = GameState.move(state, "player1", square)
      {:error, error} = GameState.move(game_state, "player2", square)
      assert error == "Square is not empty"
    end

    test "returns error when it's not the player's turn", %{game_state: state} do
      {:error, error} = GameState.move(state, "player2", 1)
      assert error == "Not your turn"
    end

    test "returns error when the player ID is unknown", %{game_state: state} do
      {:error, error} = GameState.move(state, "unknown_player", 1)
      assert error == "Player not found"
    end
  end
end
