defmodule MemoartWeb.Router do
  use MemoartWeb, :router

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MemoartWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admins_only do
    plug :basic_auth, username: "admin", password: "m3m0art"
  end
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin" do
    pipe_through [:browser, :admins_only]
    live_dashboard "/dashboard"
  end

  scope "/", MemoartWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/play", PageController, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", MemoartWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MemoartWeb.Telemetry
    end
  end
end
