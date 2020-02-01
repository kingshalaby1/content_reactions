defmodule ContentReactions.Reactions.Counter do
  @moduledoc """
    Before updating reactions' counters, we need to validate reactions so that we do not count redundant reactions

    We have `:reaction_counts` table, having `{{content_id, reaction_type}, count}`
    with `{content_id, reaction_type}` as a key
    and `:reactions` table, `{{content_id, user_id, reaction_type}, action}` for user reactions per content per reaction type

    both tables does not allow duplicate of key -first element of tuple entry-
    and updating counters is guaranteed to be unique via `:ets.update_counter`

  """

  use GenServer

  @doc """
  Starts the GenServer.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  creates a valid reaction asynchronously, or forwards invalid changeset
  """
  def create_reaction({:ok, reaction}) do
    GenServer.cast(
      __MODULE__,
      {:create, {reaction.content_id, reaction.user_id, reaction.reaction_type, reaction.action}}
    )
  end

  def create_reaction(error), do: error

  @doc """
    reads count for a reaction type
  """
  def read_count(content_id, reaction_type) do
    record = {content_id, reaction_type}

    case :ets.lookup(:reaction_counts, record) do
      [{^record, count}] ->
        {:ok, count}

      [] ->
        {:error, :not_found}
    end
  end

  ## Server callbacks

  @impl true
  def init(:ok) do
    counts = :ets.new(:reaction_counts, [:named_table, read_concurrency: true])
    reactions = :ets.new(:reactions, [:named_table, read_concurrency: true])
    {:ok, {counts, reactions}}
  end

  @impl true
  def handle_cast({:create, {content_id, user_id, reaction_type, action}}, state) do
    new_record = {{content_id, user_id, reaction_type}, action}

    case read_previous_reaction({content_id, user_id, reaction_type}) do
      ## user has no previous record for this reaction on this content
      {:ok, []} ->
        :ets.insert(:reactions, new_record)
        ensure_counter_exists(content_id, reaction_type)

        if action == 1 do
          :ets.update_counter(:reaction_counts, {content_id, reaction_type}, 1)
        end

        {:noreply, state}

      ##  user has the same reaction on this content. This is a redundant request, maybe should return 400
      {:ok, ^action} ->
        {:noreply, state}

      ## user has reaction record other than requested. Here we update the counter
      {:ok, value} ->
        case value do
          0 ->
            :ets.update_counter(:reaction_counts, {content_id, reaction_type}, 1)

          1 ->
            :ets.update_counter(:reaction_counts, {content_id, reaction_type}, -1)
        end

        :ets.insert(:reactions, new_record)
        {:noreply, state}
    end
  end

  def read_previous_reaction(record) do
    case :ets.lookup(:reactions, record) do
      [{^record, action}] ->
        {:ok, action}

      [] ->
        {:ok, []}
    end
  end

  def ensure_counter_exists(content_id, reaction_type) do
    with [] <- :ets.lookup(:reaction_counts, {content_id, reaction_type}) do
      :ets.insert(:reaction_counts, {{content_id, reaction_type}, 0})
    end
  end
end
