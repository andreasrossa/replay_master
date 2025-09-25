defmodule ReplayMaster.Repo do
  use Ecto.Repo,
    otp_app: :replay_master,
    adapter: Ecto.Adapters.Postgres
end
