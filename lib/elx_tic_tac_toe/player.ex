defmodule ElxTicTacToe.Player do
  @moduledoc """
  This module is responsible for managing the state of a player in the ElxTicTacToe application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field(:name, :string)
    field(:score, :integer, default: 0)
    field(:letter, Ecto.Enum, values: [:X, :O])
  end

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          score: integer(),
          letter: :X | :O
        }

  def changeset(params \\ %{}) do
    %Player{}
    |> cast(params, [:name, :letter])
    |> validate_required([:name])
    |> validate_length(:name, max: 15)
    |> generate_id()
  end

  def create(params) do
    params
    |> changeset()
    |> apply_action(:create)
  end

  defp generate_id(changeset) do
    case get_change(changeset, :id) do
      nil -> put_change(changeset, :id, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
