defmodule Bulls.GameServer do
    use GenServer

    alias Bulls.Game

    def reg(name) do
        {:via, Registry, {Bulls.GameReg, name}}
    end

    def start(name) do
        spec = %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, [name]},
            restart: :permanent,
            type: :worker
        }
        Bulls.GameSup.start_child(spec)
    end

    def start_link(name) do
        game = Game.begin(name)
        GenServer.start_link(
          __MODULE__,
          game,
          name: reg(name)
        )
    end

    def peek(name) do
        GenServer.call(reg(name), {:peek, name})
    end

    def joinLobby(name) do
        GenServer.call(reg(name), {:joinLobby, name})
    end

    def setPlayerType(name, type) do
        GenServer.call(reg(name), {:setPlayerType, name, type})
    end

    def setReady(name, ready) do
        GenServer.call(reg(name), {:setReady, name, ready})
    end

    def guess(name, letter) do
        GenServer.call(reg(name), {:guess, name, letter})
    end

    def reset(name) do
        GenServer.call(reg(name), {:reset, name})
    end

    def init(game) do
        Process.send_after(self(), :pook, 10_000)
        {:ok, game}
    end

    def handle_call({:peek, _name}, _from, game) do
        {:reply, game, game}
    end

    def handle_call({:joinLobby, _name}, _from, game) do
        game = Game.set_player_type(game, "player")
        {:reply, game, game}
    end

    def handle_info(:pook, game) do
        Hw05Web.Endpoint.broadcast!(
            game.gameName, # FIXME: Game name should be in state
            "view",
            Game.view(game, "", "player"))
        {:noreply, game}
    end

    def handle_call({:setPlayerType, name, type}, _from, game) do
        game = Game.set_player_type(game, type)
        {:reply, game, game}
    end

    def handle_call({:setReady, name, ready}, _from, game) do
        game = Game.set_ready(game, ready)
        {:reply, game, game}
    end

    def handle_call({:guess, name, letter}, _from, game) do
        game = Game.guess_code(game, letter)
        {:reply, game, game}
    end

    def handle_call({:reset, name}, _from, game) do
        game = Game.begin()
        {:reply, game, game}
    end
end