defmodule ContentReactionsWeb.ReactionView do
  use ContentReactionsWeb, :view
  alias ContentReactionsWeb.ReactionView

  def render("index.json", %{reactions: reactions}) do
    %{data: render_many(reactions, ReactionView, "reaction.json")}
  end

  def render("show.json", %{reaction: reaction}) do
    %{data: render_one(reaction, ReactionView, "reaction.json")}
  end

  def render("reaction.json", %{reaction: reaction}) do
    %{id: reaction.id,
      content_id: reaction.content_id,
      user_id: reaction.user_id,
      reaction_type: reaction.reaction_type,
      action: reaction.action,
      created_at: reaction.created_at
    }
  end
end
