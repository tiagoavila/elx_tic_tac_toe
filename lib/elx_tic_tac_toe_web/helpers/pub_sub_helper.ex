defmodule ElxTicTacToeWeb.Helpers.PubSubHelper do
  @moduledoc """
  This module is responsible for managing the PubSub system in the ElxTicTacToe application.
  """

  alias Phoenix.PubSub

  def subscribe(game_code) do
    PubSub.subscribe(ElxTicTacToe.PubSub, "game-#{game_code}")
  end

  def broadcast_game_state(game_code) do
    PubSub.broadcast(
          ElxTicTacToe.PubSub,
          "game-#{game_code}",
          :game_state_updated
        )
  end
end
