defmodule ElxTicTacToeWeb.Layouts.GameComponents do
  @moduledoc """
  This module is responsible for managing the game components in the ElxTicTacToe application.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def get_current_player_class(current_player, player_id, game) do
    cond do
     player_id != game.active_player_id -> ""
     current_player == game.active_player_id -> "is-current-turn"
     true -> "is-not-current-turn"
    end
  end

  def get_hover_class(current_player, game) do
    if current_player == game.active_player_id, do: "tic-tac-toe-board-active", else: "tic-tac-toe-board-not-active"
  end

  @spec send_move(String.t(), String.t(), integer()) :: no_return
  def send_move(current_player, game_code, square) do
    JS.push("send_move", value: %{square: square, current_player: current_player, game_code: game_code})
  end

  attr :game_code, :string, required: true
  def reset_game_button(assigns) do
    ~H"""
    <button
      class="mt-4 px-4 py-2 bg-blue-500 text-white font-bold rounded hover:bg-blue-600 transition ease-in-out duration-150"
      phx-click={JS.push("reset_game", value: %{game_code: @game_code})}
    >
      Play again
    </button>
    """
  end
end
