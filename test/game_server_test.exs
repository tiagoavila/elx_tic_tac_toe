defmodule GameServerTest do
  use ExUnit.Case, async: true
  alias ElxTicTacToe.{GameServer, Player}

  @game_code_dynamic_supervisor "BCDE"

  setup do
    {:ok, _} = Application.ensure_all_started(:elx_tic_tac_toe)
    # Additional setup can go here
    # on_exit(fn -> Application.stop(:elx_tic_tac_toe) end)
  end

  describe "start_link/2" do
    test "starts the server successfully with unique game code and player" do
      game_code = "ABCD"
      player = %Player{name: "player1"}

      assert {:ok, _pid} = GameServer.start_link(game_code, player)
    end

    # @tag skip: true
    test "returns :ignore if the server with the given game code is already started" do
      game_code = "ABCD"
      player1 = %Player{name: "player1"}
      player2 = %Player{name: "player2"}

      {:ok, _pid} = GameServer.start_link(game_code, player1)
      assert :ignore = GameServer.start_link(game_code, player2)
    end
  end

  describe "start_or_join_game/2" do
    test "starts a new game session if the game code is unique" do
      game_code = @game_code_dynamic_supervisor
      player = %Player{name: "player1"}

      assert {:ok, :started} = GameServer.start_or_join_game(game_code, player)

      game_state = GameServer.get_current_state(game_code)
      assert game_state.player1 != nil
      assert game_state.player1.name == "player1"
      assert game_state.player1.letter == :X
      assert game_state.status == :not_started
    end

    test "joins an existing game session if the game code is already started" do
      game_code = @game_code_dynamic_supervisor
      player2 = %Player{name: "player2"}

      assert {:ok, :joined} = GameServer.start_or_join_game(game_code, player2)

      game_state = GameServer.get_current_state(game_code)
      assert game_state.player1 != nil
      assert game_state.player2 != nil
      assert game_state.player2.name == "player2"
      assert game_state.player2.letter == :O
      assert game_state.status == :in_progress
    end
  end
end
