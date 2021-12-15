# Distrib

Playing with distributed Elixir.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * In separate shells:
    * `iex --name node_1@127.0.0.1 -S mix phx.server`
    * `iex --name node_2@127.0.0.1 -S mix phx.server`
    * `iex --name node_3@127.0.0.1 -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) etc (nodes 2 and 3
are on ports 4001 and 4002 respectively) from your browser.

Try going to the IEx shell for the node where the web page says the queue is
running (while watching the web page from a different node), and shutting the
node down:

    iex> :init.stop
