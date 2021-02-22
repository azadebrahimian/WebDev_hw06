defmodule Hw05Web.GameChannel do
  use Hw05Web, :channel

  alias Bulls.Game

  #@impl true
  #def join("game:lobby", payload, socket) do
  #  if authorized?(payload) do
  #    {:ok, socket}
  #  else
  #    {:error, %{reason: "unauthorized"}}
  #  end
  #end

  @impl true
  def join("game:" <> _id, payload, socket) do
    if authorized?(payload) do
      game = Game.begin()
      socket = assign(socket, :game, game)
      view = Game.view(game)
      {:ok, view, socket}
    end
  end

  @impl true
  def handle_in("enter", %{"letter" => l1}, socket) do
    game0 = socket.assigns[:game]
    game1 = Game.check_if_number(l1)
    socket = assign(socket, :game, game1)
    view = Game.view(game1)
    {:reply, {:ok, view}, socket}
  end

  @impl true
  def handle_in("guess", %{"letter" => l1}, socket) do
    game0 = socket.assigns[:game]
    game1 = Game.guess_code(game0, l1)
    socket = assign(socket, :game, game1)
    view = Game.view(game1)
    {:reply, {:ok, view}, socket}
  end

  @impl true
  def handle_in("reset", payload, socket) do
    game = Game.begin()
    socket = assign(socket, :game, game)
    view = Game.view(game)
    {:reply, {:ok, view}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
