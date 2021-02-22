defmodule Hw05Web.PageController do
  use Hw05Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
