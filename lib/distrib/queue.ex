defmodule Distrib.Queue do
  use GenServer
  require Logger

  def child_spec(opts) do
    name = Keyword.get(opts, :name, __MODULE__)

    %{
      id: "#{__MODULE__}_#{name}",
      start: {__MODULE__, :start_link, [name]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(name) do
    case GenServer.start_link(__MODULE__, [], name: via_tuple(name)) do
      {:ok, pid} ->
        Logger.info("Started queue at #{inspect(pid)}")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("Queue already running at #{inspect(pid)}")
        :ignore
    end
  end

  def init(_args) do
    {:ok, nil}
  end

  def via_tuple(name), do: {:via, Horde.Registry, {Distrib.Registry, name}}
end
