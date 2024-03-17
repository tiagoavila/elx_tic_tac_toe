defmodule ElxTicTacToeWeb.Layouts.GameComponents do
  @moduledoc """
  This module is responsible for managing the game components in the ElxTicTacToe application.
  """
  alias Phoenix.LiveView.JS

  def get_current_player_class(current_player, player_id, game) do
    cond do
     player_id != game.active_player -> ""
     current_player == game.active_player -> "is-current-turn"
     true -> "is-not-current-turn"
    end
  end

  def get_hover_class(current_player, game) do
    if current_player == game.active_player, do: "tic-tac-toe-board-active", else: "tic-tac-toe-board-not-active"
  end

  @spec send_move(String.t(), String.t(), integer()) :: no_return
  def send_move(current_player, game_code, square) do
    JS.push("send_move", value: %{square: square, current_player: current_player, game_code: game_code})
  end
end
