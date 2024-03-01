defmodule ElxTicTacToe.GameStarter do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  embedded_schema do
    field :player_name, :string
    field :game_code, :string
    field :type, Ecto.Enum, values: [:start, :join], default: :start
  end

  def changeset_on_start(params \\ %{}) do
    %GameStarter{}
    |> cast(params, [:player_name, :game_code])
    |> validate_required([:player_name])
  end

  def changeset_on_creation(params \\ %{}) do
    %GameStarter{}
    |> cast(params, [:player_name, :game_code])
    |> validate_required([:player_name])
    |> handle_game_code()
  end

  defp handle_game_code(changeset) do
    case changeset.valid? && get_change(changeset, :game_code) do
      nil -> put_change(changeset, :game_code, "ABCD")
      _ -> changeset
    end
  end
end
