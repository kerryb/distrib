defmodule Distrib.Queue do
  use GenServer

  require Logger

  alias Phoenix.PubSub

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
    Process.flag(:trap_exit, true)
    PubSub.subscribe(Distrib.PubSub, "tasks")
    counter = load_counter()
    report_queue_node()
    Process.send_after(self(), :start_task, :timer.seconds(1))
    {:ok, %{counter: counter}}
  end

  defp load_counter do
    {:ok, table} = :dets.open_file(__MODULE__, type: :set)

    counter =
      case :dets.lookup(__MODULE__, :counter) do
        [counter: counter] -> counter
        _ -> 1
      end

    :dets.close(table)
    counter
  end

  def terminate(_reason, state) do
    {:ok, table} = :dets.open_file(__MODULE__, type: :set)
    :dets.insert(table, {:counter, state.counter})
    :dets.close(table)
  end

  defp via_tuple(name), do: {:via, Horde.Registry, {Distrib.Registry, name}}

  def task(number) do
    Process.flag(:trap_exit, true)
    PubSub.broadcast!(Distrib.PubSub, "tasks", {:task_started, number, node()})
    Process.sleep(:timer.seconds(4))
    PubSub.broadcast!(Distrib.PubSub, "tasks", {:task_finished, number})
  end

  def handle_info(:start_task, state) do
    node = [node() | Node.list()] |> Enum.filter(&supervisor_running?/1) |> Enum.random()

    Task.Supervisor.start_child({Distrib.TaskSupervisor, node}, __MODULE__, :task, [
      state.counter
    ])

    Process.send_after(self(), :start_task, :timer.seconds(1))
    {:noreply, %{state | counter: state.counter + 1}}
  end

  def handle_info(:ping_queue, state) do
    report_queue_node()
    {:noreply, state}
  end

  def handle_info(_message, state) do
    # Logger.info("#{__MODULE__} ignoring message #{inspect(message)}")
    {:noreply, state}
  end

  defp supervisor_running?(node) do
    node |> :rpc.call(Process, :whereis, [Distrib.TaskSupervisor]) |> is_pid()
  end

  defp report_queue_node do
    PubSub.broadcast!(Distrib.PubSub, "tasks", {:queue_running, node()})
  end
end
