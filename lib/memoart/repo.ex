defmodule Memoart.Repo do
  use Ecto.Repo,
    otp_app: :memoart,
    adapter: Ecto.Adapters.Postgres
end
