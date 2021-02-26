import { Socket } from "phoenix";

let socket = new Socket(
  "/socket",
  { params: { token: "" } },
);
socket.connect();

var channel;

let state = {
  gameStarted: false,
  guess: "",
  history: [],
  guesses: 1,
  invalidGuess: false,
  won: false,
  name: "",
  gameName: "",
  totalPlayers: 0,
  totalReadies: 0,
  playersReady: false,
  playerType: "observer",
  userList: [],
  previousWinners: [],
  roundEndTime: "",
  roundStartTime: ""
};

let callback = null;

function state_update(st) {
  console.log("New state", st);
  state = st;
  if (callback) {
    callback(st);
  }
}

export function ch_join(cb) {
  callback = cb;
  callback(state);
}

export function ch_login(name, gameName) {
  channel = socket.channel("game:".concat(gameName), { name: name, gameName: gameName });
  channel.on("view", state_update);

  channel.join()
    .receive("ok", state_update)
    .receive("error", resp => {
      console.log("Unable to join", resp)
    });
}

export function ch_set_player_type(type) {
  channel.push("setType", { type: type })
    .receive("ok", state_update)
    .receive("error", resp => { console.log("Unable to push", resp) });
}

export function ch_ready_up(ready) {
  channel.push("readyUp", { ready: ready })
    .receive("ok", state_update)
    .receive("error", resp => { console.log("Unable to push", resp) });
}

export function ch_push(guess) {
  channel.push("guess", guess)
    .receive("ok", state_update)
    .receive("error", resp => { console.log("Unable to push", resp) });
}

export function ch_reset() {
  channel.push("reset", {})
    .receive("ok", state_update)
    .receive("error", resp => { console.log("Unable to push", resp) });
}