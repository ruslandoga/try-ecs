defmodule E.Repo do
  use Ecto.Repo,
    otp_app: :e,
    adapter: Ecto.Adapters.Postgres
end
