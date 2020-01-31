defmodule ContentReactionsWeb.Router do
  use ContentReactionsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ContentReactionsWeb do
    pipe_through :api
    post "/reactions", ReactionController, :create
    get "/reaction_counts/:id", ReactionController, :reaction_counts
  end
end
