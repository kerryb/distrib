defmodule DistribWeb.IndexLive do
  use DistribWeb, :live_view

  alias Phoenix.PubSub

  def render(assigns) do
    ~H"""
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
    end

    {:ok, assign(socket, tasks: [])}
  end

  def handle_info({:task_started, number}, socket) do
    {:noreply,
     assign(socket,
       tasks: [%{number: number, started?: true, finished?: false} | socket.assigns.tasks]
     )}
  end
end
