defmodule EWeb.HealthController do
  use EWeb, :controller

  def show(conn, _params) do
    json(conn, %{
      "healthy" => true,
      # TODO commit sha?
      # version: List.to_string(vsn),
      "node_name" => node(),
      # env: System.get_env(),
      "nodes" => Node.list()
      # cookie: Node.get_cookie()
    })
  end
end
