defmodule ElxTicTacToe.GameStarter do
  @moduledoc """
  This module is responsible for managing the game starter in the ElxTicTacToe application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias ElxTicTacToe.GameServer

  embedded_schema do
    field(:name, :string)
    field(:game_code, :string)
    field(:type, Ecto.Enum, values: [:start, :join], default: :start)
  end

  def starting_changeset(params \\ %{}) do
    %GameStarter{}
    |> cast(params, [:name, :game_code])
    |> validate_required([:name])
    |> validate_length(:name, max: 15)
    |> validate_length(:game_code, is: 4)
  end

  def creation_changeset(params \\ %{}) do
    %GameStarter{}
    |> cast(params, [:name, :game_code])
    |> validate_required([:name])
    |> validate_length(:name, max: 15)
    |> set_game_type()
    |> handle_game_code()
    |> ensure_game_code_uppercase()
    |> ensure_there_is_a_game_running()
  end

  @spec create(
          :invalid
          | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def create(params) do
    params
    |> creation_changeset()
    |> apply_action(:create)
  end

  def set_game_type(changeset) do
    case get_change(changeset, :game_code) do
      nil -> put_change(changeset, :type, :start)
      _ -> put_change(changeset, :type, :join)
    end
  end

  def handle_game_code(changeset) do
    with true <- changeset.valid?(),
         :start <- get_field(changeset, :type),
         nil <- get_change(changeset, :game_code) do
      case generate_game_code() do
        {:ok, game_code} -> put_change(changeset, :game_code, game_code)
        {:error, reason} -> add_error(changeset, :game_code, reason)
      end
    else
      _ -> changeset
    end
  end

  @doc """
  Generates a unique game code.
  """
  def generate_game_code() do
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.graphemes()

    codes =
      1..3
      |> Enum.map(fn _ -> Enum.map_join(1..4, fn _ -> Enum.random(alphabet) end) end)

    case Enum.find(codes, fn code -> !GameServer.server_running?(code) end) do
      nil -> {:error, "Didn't find unused code, try again later"}
      code -> {:ok, code}
    end
  end

  defp ensure_game_code_uppercase(changeset) do
    case get_change(changeset, :game_code) do
      nil -> changeset
      game_code -> put_change(changeset, :game_code, String.upcase(game_code))
    end
  end

  defp ensure_there_is_a_game_running(changeset) do
    case get_change(changeset, :game_code) do
      nil -> changeset
      game_code ->
        if GameServer.server_running?(game_code) do
          changeset
        else
          add_error(changeset, :game_code, "There is no game running with this code")
        end
    end
  end
end
