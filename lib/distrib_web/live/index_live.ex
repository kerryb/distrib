defmodule DistribWeb.IndexLive do
  use DistribWeb, :live_view

  require Logger

  alias Phoenix.PubSub

  def render(assigns) do
    ~H"""
    <p>
      <%= if @queue_node do %>
        Queue is running on <%= inspect @queue_node %>
      <% else %>
        Queue is not running
      <% end %>
    </p>

    <table>
      <tr><th>Task number</th><th>Started</th><th>Finished</th></tr>
      <%= for task <- @tasks do %>
        <tr>
          <td><%= task.number %></td>
          <td><%= if task.started?, do: "✅" %></td>
          <td><%= if task.finished?, do: "✅" %></td>
        </tr>
      <% end %>
    </table>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Distrib.PubSub, "tasks")
      PubSub.broadcast!(Distrib.PubSub, "tasks", :ping_queue)
    end

    {:ok, assign(socket, queue_node: nil, tasks: [])}
  end

  def handle_info({:queue_running, node}, socket) do
    {:noreply, assign(socket, queue_node: node)}
  end

  def handle_info({:task_started, number}, socket) do
    {:noreply,
     assign(socket,
       tasks: [%{number: number, started?: true, finished?: false} | socket.assigns.tasks]
     )}
  end

  def handle_info(message, socket) do
    Logger.info("#{__MODULE__} ignoring message #{inspect(message)}")
    {:noreply, socket}
  end
end
