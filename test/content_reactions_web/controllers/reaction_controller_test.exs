defmodule ContentReactionsWeb.ReactionControllerTest do
  use ContentReactionsWeb.ConnCase, async: false

  #  use ExMachina

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create reaction" do
    test "create reaction with valid params", %{conn: conn} do
      reaction = build_reaction()
      conn = post(conn, Routes.reaction_path(conn, :create), reaction: reaction)

      assert response(conn, 201)

      qouted =
        quote do:
                :ets.lookup(
                  :reactions,
                  {unquote(reaction.content_id), unquote(reaction.user_id),
                   unquote(reaction.reaction_type)}
                )
                |> Enum.empty?()

      assert eventually(false, qouted)

      assert {{reaction.content_id, reaction.user_id, reaction.reaction_type}, 1} in :ets.lookup(
               :reactions,
               {reaction.content_id, reaction.user_id, reaction.reaction_type}
             )
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_reaction = build_reaction(%{content_id: nil})
      conn = post(conn, Routes.reaction_path(conn, :create), reaction: invalid_reaction)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "read reactions" do
    test "it counts reactions for content", %{conn: conn} do
      reaction = build_reaction(%{reaction_type: 1})
      reaction2 = Map.put(reaction, :user_id, Ecto.UUID.generate())

      post(conn, Routes.reaction_path(conn, :create), reaction: reaction)
      post(conn, Routes.reaction_path(conn, :create), reaction: reaction2)

      conn = get(conn, Routes.reaction_path(conn, :reaction_counts, reaction.content_id))
      expected = %{"content_id" => reaction.content_id, "reaction_count" => %{"Fire" => 2}}

      assert expected == json_response(conn, 200)
    end

    test "it does not increment counter for redundant request", %{conn: conn} do
      reaction = build_reaction(%{reaction_type: 1})
      post(conn, Routes.reaction_path(conn, :create), reaction: reaction)

      conn = get(conn, Routes.reaction_path(conn, :reaction_counts, reaction.content_id))

      assert json_response(conn, 200) == %{
               "content_id" => reaction.content_id,
               "reaction_count" => %{"Fire" => 1}
             }

      post(conn, Routes.reaction_path(conn, :create), reaction: reaction)
      post(conn, Routes.reaction_path(conn, :create), reaction: reaction)

      conn = get(conn, Routes.reaction_path(conn, :reaction_counts, reaction.content_id))

      assert json_response(conn, 200) == %{
               "content_id" => reaction.content_id,
               "reaction_count" => %{"Fire" => 1}
             }
    end

    test "it decrements counter for `remove` action", %{conn: conn} do
      reaction = build_reaction(%{reaction_type: 1})
      post(conn, Routes.reaction_path(conn, :create), reaction: reaction)

      conn = get(conn, Routes.reaction_path(conn, :reaction_counts, reaction.content_id))

      assert json_response(conn, 200) == %{
               "content_id" => reaction.content_id,
               "reaction_count" => %{"Fire" => 1}
             }

      post(conn, Routes.reaction_path(conn, :create), reaction: Map.put(reaction, :action, 0))

      conn = get(conn, Routes.reaction_path(conn, :reaction_counts, reaction.content_id))

      assert json_response(conn, 200) == %{
               "content_id" => reaction.content_id,
               "reaction_count" => %{"Fire" => 0}
             }
    end

    test "it decrements counter for `remove` action only if a user added a reaction before", %{
      conn: conn
    } do
      user1_reaction = build_reaction(%{reaction_type: 1})

      user2_reaction_remove =
        build_reaction(%{
          content_id: user1_reaction.content_id,
          user_id: Ecto.UUID.generate(),
          reaction_type: 1,
          action: 0
        })

      post(conn, Routes.reaction_path(conn, :create), reaction: user1_reaction)
      conn = get(conn, Routes.reaction_path(conn, :reaction_counts, user1_reaction.content_id))

      assert json_response(conn, 200) == %{
               "content_id" => user1_reaction.content_id,
               "reaction_count" => %{"Fire" => 1}
             }

      post(conn, Routes.reaction_path(conn, :create), reaction: user2_reaction_remove)

      conn =
        get(conn, Routes.reaction_path(conn, :reaction_counts, user2_reaction_remove.content_id))

      assert json_response(conn, 200) == %{
               "content_id" => user2_reaction_remove.content_id,
               "reaction_count" => %{"Fire" => 1}
             }
    end

    test "it returns 404 for content that has no reactions at all ", %{conn: conn} do
      conn = get(conn, Routes.reaction_path(conn, :reaction_counts, Ecto.UUID.generate()))
      assert json_response(conn, 404) == %{"message" => "content not found"}
    end
  end

  def build_reaction(args \\ %{}) do
    %{
      action: 1,
      content_id: Ecto.UUID.generate(),
      reaction_type: Enum.random([1, 2, 3]),
      user_id: Ecto.UUID.generate()
    }
    |> Map.merge(args)
  end

  def eventually(expected, exercise, times \\ 10)
  def eventually(_expected, _exercise, 0), do: false

  def eventually(expected, exercise, times) do
    if expected == Code.eval_quoted(exercise) |> elem(0) do
      true
    else
      eventually(expected, exercise, times - 1)
    end
  end
end
