defmodule ContentReactionsWeb.ReactionController do
  use ContentReactionsWeb, :controller

  alias ContentReactions.Reactions
  alias ContentReactions.Reactions.Reaction

  action_fallback ContentReactionsWeb.FallbackController

#  def index(conn, _params) do
#    reactions = Reactions.list_reactions()
#    render(conn, "index.json", reactions: reactions)
#  end

  def create(conn, %{"reaction" => reaction_params}) do
    with {:ok, %Reaction{} = reaction} <- Reactions.create_reaction(reaction_params) do
#      send_resp(conn, :created, "")
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.reaction_path(conn, :show, reaction))
      |> render("show.json", reaction: reaction)
    end
  end

#  def show(conn, %{"id" => id}) do
#    reaction = Reactions.get_reaction!(id)
#    render(conn, "show.json", reaction: reaction)
#  end
#
#  def update(conn, %{"id" => id, "reaction" => reaction_params}) do
#    reaction = Reactions.get_reaction!(id)
#
#    with {:ok, %Reaction{} = reaction} <- Reactions.update_reaction(reaction, reaction_params) do
#      render(conn, "show.json", reaction: reaction)
#    end
#  end
#
#  def delete(conn, %{"id" => id}) do
#    reaction = Reactions.get_reaction!(id)
#
#    with {:ok, %Reaction{}} <- Reactions.delete_reaction(reaction) do
#      send_resp(conn, :no_content, "")
#    end
#  end
end
