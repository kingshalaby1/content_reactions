defmodule ContentReactions.Reactions do
  @moduledoc """
  The Reactions context.
  """
  use EnumType

  defenum ReactionTypes do
    value(Fire, 1)
    value(Like, 2)
    value(Celebrate, 3)

    default(Fire)
  end

  alias ContentReactions.Reactions.{Reaction, Counter}

  def get_reaction_counts(content_id) do
    results =
      Enum.reduce(ReactionTypes.enums(), %{}, fn type, acc ->
        case Counter.read_count(content_id, type.value) do
          {:ok, count} ->
            acc
            |> Map.put_new(
              type
              |> Atom.to_string()
              |> String.split(".")
              |> List.last(),
              count
            )

          {:error, :not_found} ->
            acc
        end
      end)

    if Enum.empty?(results) do
      {:error, :not_found}
    else
      {:ok, results}
    end
  end

  @doc """
  Creates a reaction.

  ## Examples

      iex> create_reaction(%{field: value})
      {:ok, %Reaction{}}

      iex> create_reaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reaction(attrs \\ %{}) do
    %Reaction{}
    |> Reaction.changeset(attrs)
    |> validate_reaction()
    |> Counter.create_reaction()
  end

  defp validate_reaction(%Ecto.Changeset{valid?: true} = params) do
    {:ok, params.changes}
  end

  defp validate_reaction(changeset), do: {:error, changeset}
end
