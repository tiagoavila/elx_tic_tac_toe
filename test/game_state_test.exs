defmodule ElxTicTacToe.GameStateTest do
  @moduledoc """
  This module is responsible for testing the ElxTicTacToe.GameState module.
  """

  use ExUnit.Case
  alias ElxTicTacToe.{GameState, Player}

  setup do
    {:ok,
     game_state: %GameState{
       code: "ABCD",
       player1: %{id: "player1", name: "player1", letter: :X},
       player2: %{id: "player2", name: "player2", letter: :O},
       active_player_id: "player1",
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
      assert game_state.active_player_id == nil
      assert game_state.status == :not_started
    end
  end

  describe "join/2" do
    test "returns an error when trying to join a game without an initial player" do
      game_state = %GameState{}
      {:error, _message} = GameState.join(game_state, %Player{name: "player2"})
    end

    test "returns an error when the game already has two players" do
      game_state = %GameState{
        player1: %Player{name: "player1"},
        player2: %Player{name: "player2"}
      }

      {:error, _message} = GameState.join(game_state, %Player{name: "player3"})
    end

    test "updates the game state when a second player joins successfully" do
      game_state = GameState.new("game123", %Player{name: "player1"})
      updated_game_state = GameState.join(game_state, %Player{name: "player2"})

      assert updated_game_state.player2.name == "player2"
      # assert updated_game_state.active_player_id == "player1"
      assert updated_game_state.status == :in_progress
    end
  end

  describe "move/3" do
    test "makes a valid move", %{game_state: state} do
      square = 1
      game_state = GameState.move(state, "player1", square)
      assert game_state.board[square] == "X"
      assert game_state.active_player_id == "player2"

      game_state = GameState.move(game_state, "player2", 2)
      assert game_state.board[2] == "O"
      assert game_state.active_player_id == "player1"
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

    test "updates the game state with a winner", %{game_state: state} do
      moves = [1, 4, 2, 5, 3]
      final_state = Enum.reduce(moves, state, fn square, acc_state ->
        GameState.move(acc_state, acc_state.active_player_id, square)
      end)

      assert final_state.status == :finished_with_winner
      assert final_state.winner != nil
      assert final_state.winner.name == "player1"
    end

    test "ends the game with a draw when the board is full", %{game_state: state} do
      moves = [1, 2, 3, 5, 4, 6, 8, 7, 9]
      final_state = Enum.reduce(moves, state, fn square, acc_state ->
        GameState.move(acc_state, acc_state.active_player_id, square)
      end)

      assert final_state.status == :finished_with_draw
    end
  end

  describe "is_there_winner??/1" do
    test "returns true for a winning row" do
      board = %{
        1 => "X",
        2 => "X",
        3 => "X",
        4 => nil,
        5 => nil,
        6 => nil,
        7 => nil,
        8 => nil,
        9 => nil
      }

      assert GameState.is_there_winner?(board) == true
    end

    test "returns true for a winning column" do
      board = %{
        1 => "O",
        2 => nil,
        3 => nil,
        4 => "O",
        5 => nil,
        6 => nil,
        7 => "O",
        8 => nil,
        9 => nil
      }

      assert GameState.is_there_winner?(board) == true
    end

    test "returns true for a winning diagonal" do
      board = %{
        1 => "X",
        2 => nil,
        3 => nil,
        4 => nil,
        5 => "X",
        6 => nil,
        7 => nil,
        8 => nil,
        9 => "X"
      }

      assert GameState.is_there_winner?(board) == true
    end

    test "returns false when there is no winner" do
      board = %{
        1 => "X",
        2 => "O",
        3 => "X",
        4 => "X",
        5 => "O",
        6 => "O",
        7 => "O",
        8 => "X",
        9 => "X"
      }

      assert GameState.is_there_winner?(board) == false
    end

    test "returns false for an empty board" do
      board = %{
        1 => nil,
        2 => nil,
        3 => nil,
        4 => nil,
        5 => nil,
        6 => nil,
        7 => nil,
        8 => nil,
        9 => nil
      }

      assert GameState.is_there_winner?(board) == false
    end
  end

  describe "is_board_full?/1" do
    test "returns true when the board is full" do
      board = %{
        1 => "X",
        2 => "O",
        3 => "X",
        4 => "O",
        5 => "X",
        6 => "O",
        7 => "X",
        8 => "O",
        9 => "X"
      }

      state = %GameState{board: board}
      assert GameState.is_board_full?(state) == true
    end

    test "returns false when the board is not full" do
      board = %{
        1 => "X",
        2 => "O",
        3 => "X",
        4 => "O",
        5 => nil,
        6 => "O",
        7 => "X",
        8 => "O",
        9 => "X"
      }

      state = %GameState{board: board}
      assert GameState.is_board_full?(state) == false
    end

    test "returns false for an empty board" do
      board = %{
        1 => nil,
        2 => nil,
        3 => nil,
        4 => nil,
        5 => nil,
        6 => nil,
        7 => nil,
        8 => nil,
        9 => nil
      }

      state = %GameState{board: board}
      assert GameState.is_board_full?(state) == false
    end
  end

  describe "reset_game/1" do
    test "resets the game to its initial state" do
      player1 = %Player{id: "player1", name: "player1", letter: :X, score: 0}
      player2 = %Player{id: "player2", name: "player2", letter: :O, score: 0}

      initial_state = %GameState{
        player1: player1,
        player2: player2,
        active_player_id: "player2",
        winner: player1,
        status: :finished_with_winner,
        board: %{
          1 => :X, 2 => :O, 3 => :X,
          4 => :O, 5 => :X, 6 => :O,
          7 => :X, 8 => :O, 9 => :X
        }
      }

      reset_state = GameState.reset_game(initial_state)

      assert reset_state.status == :in_progress
      assert reset_state.winner == nil
      assert reset_state.active_player_id == "player1"
      assert Enum.all?(Map.values(reset_state.board), &(&1 == nil))
    end
  end
end
