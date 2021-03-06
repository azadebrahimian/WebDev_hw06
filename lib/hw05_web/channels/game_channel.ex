defmodule Hw05Web.GameChannel do
  use Hw05Web, :channel

  alias Bulls.Game
  alias Bulls.GameServer

  @impl true
  def join("game:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      socket = socket
      |> assign(:name, name)
      |> assign(:user, Map.get(payload, "name"))
      |> assign(:playerType, "observer")
      game = GameServer.peek(name)
      view = socket.assigns[:name]
      |> GameServer.addUser(Map.get(payload, "name"))
      |> Game.view(Map.get(payload, "name"), "observer")
      {:ok, view, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("setType", %{"type" => type}, socket) do
    socket = assign(socket, :playerType, type)
    playerType = socket.assigns[:playerType]
    user = socket.assigns[:user]
    view = socket.assigns[:name]
    |> GameServer.setPlayerType(type, user)
    |> Game.view(user, playerType)
    broadcast(socket, "view", view)
    {:reply, {:ok, view}, socket}
  end

  @impl true
  def handle_in("readyUp", %{"ready" => ready}, socket) do
    user = socket.assigns[:user]
    playerType = socket.assigns[:playerType]
    view = socket.assigns[:name]
    |> GameServer.setReady(ready)
    |> Game.view(user, playerType)
    broadcast(socket, "view", view)
    {:reply, {:ok, view}, socket}
  end

  @impl true
  def handle_in("guess", %{"letter" => l1}, socket) do
    user = socket.assigns[:user]
    playerType = socket.assigns[:playerType]
    view = socket.assigns[:name]
    |> GameServer.guess(l1, user)
    |> Game.view(user, playerType)
    broadcast(socket, "view", view)
    {:reply, {:ok, view}, socket}
  end

  intercept ["view"]

  @impl true
  def handle_out("view", msg, socket) do
    user = socket.assigns[:user]
    playerType = socket.assigns[:playerType]
    msg = %{msg | name: user}
    msg = %{msg | playerType: playerType}
    push(socket, "view", msg)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
