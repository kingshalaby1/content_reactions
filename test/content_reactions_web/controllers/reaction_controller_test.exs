defmodule ContentReactionsWeb.ReactionControllerTest do
  use ContentReactionsWeb.ConnCase

  alias ContentReactions.Reactions
  alias ContentReactions.Reactions.Reaction

  @create_attrs %{
    action: 42,
    content_id: "7488a646-e31f-11e4-aace-600308960662",
    reaction_type: 42,
    user_id: "7488a646-e31f-11e4-aace-600308960662"
  }
  @invalid_attrs %{action: nil, content_id: nil, reaction_type: nil, user_id: nil}

  def fixture(:reaction) do
    {:ok, reaction} = Reactions.create_reaction(@create_attrs)
    reaction
  end

  setup_all %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all reactions", %{conn: conn} do
      conn = get(conn, Routes.reaction_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create reaction" do
    test "renders reaction when data is valid", %{conn: conn} do
      conn = post(conn, Routes.reaction_path(conn, :create), reaction: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.reaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "action" => 42,
               "content_id" => "7488a646-e31f-11e4-aace-600308960662",
               "reaction_type" => 42,
               "user_id" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.reaction_path(conn, :create), reaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update reaction" do
    setup [:create_reaction]

    test "renders reaction when data is valid", %{
      conn: conn,
      reaction: %Reaction{id: id} = reaction
    } do
      conn = put(conn, Routes.reaction_path(conn, :update, reaction), reaction: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.reaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "action" => 43,
               "content_id" => "7488a646-e31f-11e4-aace-600308960668",
               "reaction_type" => 43,
               "user_id" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, reaction: reaction} do
      conn = put(conn, Routes.reaction_path(conn, :update, reaction), reaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete reaction" do
    setup [:create_reaction]

    test "deletes chosen reaction", %{conn: conn, reaction: reaction} do
      conn = delete(conn, Routes.reaction_path(conn, :delete, reaction))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.reaction_path(conn, :show, reaction))
      end
    end
  end

  defp create_reaction(_) do
    reaction = fixture(:reaction)
    {:ok, reaction: reaction}
  end
end
