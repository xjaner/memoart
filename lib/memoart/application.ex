defmodule Memoart.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # Memoart.Repo,
      # Start the Telemetry supervisor
      MemoartWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Memoart.PubSub},
      # Start the Endpoint (http/https)
      MemoartWeb.Endpoint,
      # Start a worker by calling: Memoart.Worker.start_link(arg)
      # {Memoart.Worker, arg}
      MemoartWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Memoart.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MemoartWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
