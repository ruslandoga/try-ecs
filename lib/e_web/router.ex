defmodule EWeb.Router do
  use EWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {EWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EWeb do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/", EWeb do
    pipe_through :api
    get "/health", HealthController, :show
  end

  scope "/" do
    pipe_through :browser
    live_dashboard "/dashboard", metrics: EWeb.Telemetry
  end
end
