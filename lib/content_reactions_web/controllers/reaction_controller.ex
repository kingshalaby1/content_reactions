defmodule ContentReactionsWeb.ReactionController do
  use ContentReactionsWeb, :controller

  alias ContentReactions.Reactions

  action_fallback ContentReactionsWeb.FallbackController

  def create(conn, %{"reaction" => reaction_params}) do
    with :ok <- Reactions.create_reaction(reaction_params) do
      send_resp(conn, :created, "")
    end
  end

  def reaction_counts(conn, %{"id" => id}) do
    case Reactions.get_reaction_counts(id) do
      {:ok, counts} ->
        body = %{content_id: id, counts: counts}
        render(conn, "reactions_count.json", reaction_counts: body)

      {:error, :not_found} ->
        send_resp(conn, :not_found, "content not found")
    end
  end
end
