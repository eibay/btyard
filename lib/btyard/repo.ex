defmodule Btyard.Repo do
  use Ecto.Repo,
    otp_app: :btyard,
    adapter: Ecto.Adapters.Postgres
end
