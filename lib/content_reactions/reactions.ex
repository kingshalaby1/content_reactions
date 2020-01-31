defmodule ContentReactions.Reactions do
  @moduledoc """
  The Reactions context.
  """

#  import Ecto.Query, warn: false
#  alias ContentReactions.Repo

  alias ContentReactions.Reactions.{Reaction, Counter}


  @doc """
  Creates a reaction.

  ## Examples

      iex> create_reaction(%{field: value})
      {:ok, %Reaction{}}

      iex> create_reaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reaction(attrs \\ %{}) do
#    %Reaction{}
#    |> Reaction.changeset(attrs)
#    |> Repo.insert()

    attrs = Map.put_new(attrs, "created_at", DateTime.utc_now())

    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Counter.insert()
  end


  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reaction changes.

  ## Examples

      iex> change_reaction(reaction)
      %Ecto.Changeset{source: %Reaction{}}

  """
  def change_reaction(%Reaction{} = reaction) do
    Reaction.changeset(reaction, %{})
  end
end
