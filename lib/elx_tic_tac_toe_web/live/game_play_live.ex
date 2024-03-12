defmodule ElxTicTacToeWeb.GamePlayLive do
  use ElxTicTacToeWeb, :live_view

  alias ElxTicTacToe.GameState

  def mount(%{"game" => game_code, "player" => player_id}, _session, socket) do
    {:ok, socket |> assign(game_code: game_code, player_id: player_id)}
  end
end
