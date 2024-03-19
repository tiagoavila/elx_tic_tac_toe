defmodule ElxTicTacToe.GameState do
  @moduledoc """
  This module is responsible for managing the state of a game session in the ElxTicTacToe application.
  """

  alias ElxTicTacToe.Player

  defstruct code: nil,
            player1: nil,
            player2: nil,
            active_player_id: nil,
            status: :not_started,
            winner: nil,
            board: %{
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

  @type t :: %__MODULE__{
          code: String.t(),
          player1: Player.t(),
          player2: Player.t(),
          active_player_id: String.t(),
          winner: Player.t(),
          status: :not_started | :in_progress | :finished_with_winner | :finished_with_draw,
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

  def join(%__MODULE__{player1: player1, player2: player2}, _)
      when player1 != nil and player2 != nil do
    {:error, "Only 2 players allowed"}
  end

  def join(%__MODULE__{player1: player1, player2: nil} = state, player2) do
    player2 = %Player{player2 | letter: :O}
    %__MODULE__{state | player2: player2, active_player_id: player1.id, status: :in_progress}
  end

  @spec move(ElxTicTacToe.GameState.t(), String.t(), any()) ::
          {:error, <<_::104, _::_*24>>} | ElxTicTacToe.GameState.t()
  def move(%__MODULE__{board: board, active_player_id: active_player_id} = state, player_id, square) do
    with {:ok, player} <- get_player_by_id(state, player_id),
         true <- is_current_player_turn?(state, player_id),
         true <- square_is_empty?(state, square) do
      letter = player.letter |> Atom.to_string()
      new_board = Map.put(board, square, letter)

      cond do
        is_there_winner?(new_board) ->
          player = Map.update(player, :score, 1, &(&1 + 1))

          state =
            if player.id == state.player1.id,
              do: state |> Map.replace(:player1, player),
              else: state |> Map.replace(:player2, player)

          %__MODULE__{state | board: new_board, winner: player, status: :finished_with_winner}

        is_board_full?(%__MODULE__{board: new_board}) ->
          %__MODULE__{state | board: new_board, status: :finished_with_draw}

        true ->
          next_player = set_next_player(active_player_id, state)

          %__MODULE__{state | board: new_board, active_player_id: next_player}
      end
    else
      :not_your_turn -> {:error, "Not your turn"}
      :square_is_not_empty -> {:error, "Square is not empty"}
      :player_not_found -> {:error, "Player not found"}
    end
  end

  @spec is_there_winner?(Map.t()) :: boolean()
  def is_there_winner?(board) do
    winning_combinations = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9],
      [1, 5, 9],
      [3, 5, 7]
    ]

    Enum.any?(winning_combinations, fn [a, b, c] ->
      same?([board[a], board[b], board[c]])
    end)
  end

  def is_board_full?(%__MODULE__{board: board}) do
    Enum.all?(Map.values(board), &(&1 != nil))
  end

  def reset_game(%__MODULE__{} = state) do
    %__MODULE__{
      state
      | status: :in_progress,
        winner: nil,
        active_player_id: state.player1.id,
        board: %{
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
    }
  end

  defp is_current_player_turn?(%__MODULE__{active_player_id: active_player_id}, player_id) do
    if active_player_id == player_id, do: true, else: :not_your_turn
  end

  defp square_is_empty?(%__MODULE__{board: board}, square) do
    if Map.get(board, square) == nil, do: true, else: :square_is_not_empty
  end

  defp get_player_by_id(%__MODULE__{player1: player1, player2: player2}, player_id) do
    cond do
      player_id == player1.id -> {:ok, player1}
      player_id == player2.id -> {:ok, player2}
      true -> :player_not_found
    end
  end

  defp set_next_player(active_player_id, state) do
    if active_player_id == state.player1.id, do: state.player2.id, else: state.player1.id
  end

  defp same?([h | t]) when not is_nil(h) do
    Enum.all?(t, &(&1 == h))
  end

  defp same?(_), do: false
end
