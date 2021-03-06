defmodule Distrib.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @hosts [:"node_1@127.0.0.1", :"node_2@127.0.0.1", :"node_3@127.0.0.1"]

  @impl true
  def start(_type, _args) do
    topologies = [default: [strategy: Cluster.Strategy.Epmd, config: [hosts: @hosts]]]

    children = [
      {Horde.Registry, [name: Distrib.Registry, keys: :unique, members: registry_members()]},
      {Horde.DynamicSupervisor,
       [
         name: Distrib.DynamicSupervisor,
         strategy: :one_for_one,
         distribution_strategy: Horde.UniformQuorumDistribution,
         max_restarts: 100_000,
         max_seconds: 1,
         members: supervisor_members()
       ]},
      {Cluster.Supervisor, [topologies, [name: Distrib.ClusterSupervisor]]},
      {Phoenix.PubSub, name: Distrib.PubSub},
      DistribWeb.Telemetry,
      DistribWeb.Endpoint,
      {Task.Supervisor, name: Distrib.TaskSupervisor},

      # Start singleton process once all nodes are up.
      # Based on https://github.com/derekkraan/horde/blob/master/examples/hello_world/lib/hello_world/application.ex
      %{
        id: Distrib.ClusterConnector,
        restart: :transient,
        start:
          {Task, :start_link,
           [
             fn ->
               Horde.DynamicSupervisor.wait_for_quorum(Distrib.DynamicSupervisor, 30_000)
               Horde.DynamicSupervisor.start_child(Distrib.DynamicSupervisor, Distrib.Queue)
             end
           ]}
      }
    ]

    opts = [strategy: :one_for_one, name: Distrib.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp registry_members, do: Enum.map(@hosts, &{Distrib.Registry, &1})
  defp supervisor_members, do: Enum.map(@hosts, &{Distrib.DynamicSupervisor, &1})

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DistribWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
