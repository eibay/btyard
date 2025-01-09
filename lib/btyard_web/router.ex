defmodule BtyardWeb.Router do
  use BtyardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BtyardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :verse
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # custom plug: verse
  def verse(conn, _opts) do
    verse = ~w(Matthew Mark Luke John) |> Enum.random()
    conn = assign(conn, :verse, verse)
    IO.inspect(conn)
  end

  scope "/", BtyardWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", BtyardWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:btyard, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BtyardWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/soap", BtyardWeb do
      get "/wsdl", SoapController, :wsdl
      post "/handle_request", SoapController, :handle_request
    end
  end
end
