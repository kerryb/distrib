# Distrib

Playing with distributed Elixir.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * In two separate shells:
    * `iex --name node_1@127.0.0.1 -S mix phx.server`
    * `iex --name node_2@127.0.0.1 -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) (node 1) and
[`localhost:4001`](http://localhost:4001) (node 2) from your browser.
