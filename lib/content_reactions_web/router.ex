defmodule ContentReactionsWeb.Router do
  use ContentReactionsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ContentReactionsWeb do
    pipe_through :api
  end
end
