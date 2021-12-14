defmodule DistribWeb.PageController do
  use DistribWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
