defmodule E.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      ecs_app: [
        strategy: Cluster.Strategy.DNSPoll,
        config: [
          polling_interval: 1000,
          query: "ecs-test.ecs-test.local",
          node_basename: "ecs-test"
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: E.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      EWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: E.PubSub},
      # Start the Endpoint (http/https)
      EWeb.Endpoint
      # Start a worker by calling: E.Worker.start_link(arg)
      # {E.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: E.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
