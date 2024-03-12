defmodule ElxTicTacToe.GameStarter do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias ElxTicTacToe.GameServer

  embedded_schema do
    field(:player_name, :string)
    field(:game_code, :string)
    field(:type, Ecto.Enum, values: [:start, :join], default: :start)
  end

  def starting_changeset(params \\ %{}) do
    %GameStarter{}
    |> cast(params, [:player_name, :game_code])
    |> validate_required([:player_name])
  end

  def creation_changeset(params \\ %{}) do
    %GameStarter{}
    |> cast(params, [:player_name, :game_code])
    |> validate_required([:player_name])
    |> validate_length(:player_name, max: 15)
    |> set_game_type()
    |> handle_game_code()
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
end
