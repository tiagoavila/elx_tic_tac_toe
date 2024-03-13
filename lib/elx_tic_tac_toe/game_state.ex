defmodule ElxTicTacToe.GameState do
  @moduledoc """
  This module is responsible for managing the state of a game session in the ElxTicTacToe application.
  """

  alias ElxTicTacToe.Player

  defstruct code: nil,
            player1: nil,
            player2: nil,
            current_player: nil,
            status: :not_started,
            board: %{
              1 => nil, 2 => nil, 3 => nil,
              4 => nil, 5 => nil, 6 => nil,
              7 => nil, 8 => nil, 9 => nil
            }

  @type t :: %__MODULE__{
          code: String.t(),
          player1: Player.t(),
          player2: Player.t(),
          current_player: String.t(),
          status: :not_started | :in_progress | :finished,
          board: %{
            integer() => nil | :X | :O
          }
        }

  def new(code, player1) do
    player1 = %Player{player1 | letter: :X}
    %__MODULE__{code: code, player1: player1}
  end

  def join(%__MODULE__{player1: nil}, _) do
    {:error, "Can only join a game with a player"}
  end

  def join(%__MODULE__{player1: player1, player2: player2}, _) when player1 != nil and player2 != nil do
    {:error, "Only 2 players allowed"}
  end

  def join(%__MODULE__{player1: player1, player2: nil} = state, player2) do
    player2 = %Player{player2 | letter: :O}
    %__MODULE__{state | player2: player2, current_player: player1.id, status: :in_progress}
  end
end
