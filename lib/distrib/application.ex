defmodule Distrib.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      default: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :"web_1@127.0.0.1",
            :"web_2@127.0.0.1",
            :"tasks_1@127.0.0.1",
            :"tasks_2@127.0.0.1"
          ]
        ]
      ]
    ]

    children = [
      # libcluster supervisor
      {Cluster.Supervisor, [topologies, [name: Distrib.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      DistribWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Distrib.PubSub},
      # Start the Endpoint (http/https)
      DistribWeb.Endpoint
      # Start a worker by calling: Distrib.Worker.start_link(arg)
      # {Distrib.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Distrib.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DistribWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
