defmodule BtyardWeb.Router do
  use BtyardWeb, :router

  import BtyardWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BtyardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :verse
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :redirect_if_user_is_authenticated do
    plug BtyardWeb.Plugs.RedirectIfAuthenticated
  end

  pipeline :require_authenticated_user do
    plug BtyardWeb.Plugs.RequireAuthenticatedUser
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

  ## Authentication routes

  scope "/", BtyardWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BtyardWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", BtyardWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BtyardWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", BtyardWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
