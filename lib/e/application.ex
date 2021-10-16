defmodule E.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {Finch, name: E.Finch},
        maybe_cluster(),
        # Start the Telemetry supervisor
        EWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: E.PubSub},
        # Start the Endpoint (http/https)
        EWeb.Endpoint
        # Start a worker by calling: E.Worker.start_link(arg)
        # {E.Worker, arg}
      ]
      |> Enum.reject(&is_nil/1)

    node = node()

    unless node == :nonode@nohost do
      :logger.update_primary_config(%{metadata: %{node: node}})
    end

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

  defp maybe_cluster do
    if topologies = Application.get_env(:libcluster, :topologies) do
      {Cluster.Supervisor, [topologies, [name: E.Cluster.Supervisor]]}
    end
  end
end
