defmodule ElxTicTacToeWeb.GamePlayLive do
  use ElxTicTacToeWeb, :live_view

  alias ElxTicTacToe.{GameState, GameServer}

  def mount(%{"game" => game_code, "player" => player_id}, _session, socket) do
    game_state = GameServer.get_current_state(game_code)
    {:ok, socket |> assign(game_code: game_code, player_id: player_id, game: game_state)}
  end
end
