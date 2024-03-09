defmodule GameServerTest do
  use ExUnit.Case, async: true
  alias ElxTicTacToe.GameServer

  @game_code_dynamic_supervisor "BCDE"

  setup do
    {:ok, _} = Application.ensure_all_started(:elx_tic_tac_toe)
    # Additional setup can go here
  end

  describe "start_link/2" do
    test "starts the server successfully with unique game code and player" do
      game_code = "ABCD"
      player = "player1"

      assert {:ok, _pid} = GameServer.start_link(game_code, player)
    end

    # @tag skip: true
    test "returns :ignore if the server with the given game code is already started" do
      game_code = "ABCD"
      player1 = "player1"
      player2 = "player2"

      {:ok, _pid} = GameServer.start_link(game_code, player1)
      assert :ignore = GameServer.start_link(game_code, player2)
    end
  end

  describe "start_or_join_game/2" do
    test "starts a new game session if the game code is unique" do
      game_code = @game_code_dynamic_supervisor
      player = "player1"

      assert {:ok, :started, _pid} = GameServer.start_or_join_game(game_code, player)
    end

    test "joins an existing game session if the game code is already started" do
      game_code = @game_code_dynamic_supervisor
      player2 = "player2"

      assert {:ok, :joined} = GameServer.start_or_join_game(game_code, player2)
    end
  end
end
