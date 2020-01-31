defmodule ContentReactions.Reactions.Counter do
  @moduledoc false

  alias ContentReactions.Reactions.Reaction

  def insert(arg) do
    IO.inspect(arg.changes.content_id)
    reaction = %Reaction{
      id: Ecto.UUID.generate(),
      action: arg.changes.action,
      content_id: arg.changes.content_id,
      reaction_type: arg.changes.reaction_type,
      user_id: arg.changes.user_id,
      created_at: arg.changes.created_at
    }


    {:ok, reaction}
  end

end
