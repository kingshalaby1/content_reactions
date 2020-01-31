defmodule ContentReactions.Reactions.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reactions" do
    field(:action, :integer)
    field(:content_id, Ecto.UUID)
    field(:reaction_type, :integer)
    field(:user_id, Ecto.UUID)
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:content_id, :user_id, :reaction_type, :action])
    |> validate_required([:content_id, :user_id, :reaction_type, :action])
  end
end
