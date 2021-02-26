import React, { useState, useEffect } from 'react';
import {
  ch_login, ch_join, ch_push,
  ch_set_player_type, ch_ready_up
} from './socket';

function Bulls() {
  const [state, setState] = useState({
    history: [],
    guesses: 1,
    invalidGuess: false,
    won: false,
    name: "",
    gameName: "",
    playersReady: false,
    ready: false,
    playerType: "player",
    totalPlayers: 0,
    totalReadies: 0,
    userList: [],
    previousWinners: []
  });
  const [guess, setGuess] = useState("");
  const [recentGuess, setRecentGuess] = useState("")

  let { name, gameName, history, userList, previousWinners } = state;

  useEffect(() => {
    ch_join(setState);
  });

  function checkIfNumber(e) {
    if (isNaN(e)) {
      return
    } else {
      setGuess(e);
    }
  }

  function guessCode() {
    ch_push({ letter: guess });
    setRecentGuess(guess);
    setGuess("");
  }

  function guessPass() {
    ch_push({ letter: "pass" });
    setRecentGuess("pass");
    setGuess("");
  }

  function printHistory() {
    const items = []

    let c = 1;
    for (const h of history) {
      items.push(
        <tr key={c}>
          <td>{h["roundNo"]}</td>
          <td>{h["user"]}</td>
          <td>{h["guess"]}</td>
          <td className="Bull-col">{h["bulls"]}</td>
          <td className="Cow-col">{h["cows"]}</td>
        </tr>
      )
      c++;
    }

    return items
  }

  function printScore() {
    const items = []

    let c = 1;
    for (const h of userList) {
      items.push(
        <tr key={c}>
          <td>{h["user"]}</td>
          <td>{h["wins"]}</td>
          <td>{h["losses"]}</td>
        </tr>
      )
      c++;
    }

    return items
  }

  function clickOnEnter(e) {
    if (e.key === "Enter") {
      guessCode();
    }
  }

  if (state.name === "" || state.gameName === "") {
    return (
      <Login />
    );
  }



  if (!state.playersReady) {
    return (
      <div>
        <p>Game Name: {gameName}</p>
        <p>Name: {name}</p>
        <Setup state={state} />
        <p>Previous Winners: {previousWinners.toString()}</p>
        <div id="Scoreboard">
          <table id="Scoreboard-table">
            <thead>
              <tr>
                <th>Player</th>
                <th>Wins</th>
                <th>Losses</th>
              </tr>
            </thead>
            <tbody>
              {printScore()}
            </tbody>
          </table>
        </div>
      </div>
    );
  }

  function checkIfInvalid(n) {
    var s = Array.from(new Set(n));
    return (s.length !== n.length) || n.length !== 4;
  }

  function calcGuess(g) {
    if (checkIfInvalid(g) && (g !== "") && (g !== "pass")) {
      return ("Invalid");
    } else {
      return (g);
    }
  }

  return (
    <div className="Game">
      <p>Game Name: {gameName}</p>
      <p>Name: {name}</p>
      <div id="History">
        <table id="History-table">
          <thead>
            <tr>
              <th>Round</th>
              <th>User</th>
              <th>Guess</th>
              <th className="Bull-col">Bulls</th>
              <th className="Cow-col">Cows</th>
            </tr>
          </thead>
          <tbody>
            {printHistory()}
          </tbody>
        </table>
      </div>
      {state.playerType === "player" &&
        <div id="Base">
          <input
            value={guess}
            id="Guess"
            maxLength="4"
            onChange={(e) => checkIfNumber(e.target.value)}
            onKeyPress={clickOnEnter}
          ></input>
          <button className="Base-button" onClick={guessCode}>
            Go!
        </button>
          <button onClick={guessPass}>
            Pass
          </button>
          <p>Current Guess: {calcGuess(recentGuess)}</p>
        </div>}
    </div >
  );
}

function Login() {
  // Login code taken from Hangman notes
  const [name, setName] = useState("");
  const [gameName, setGameName] = useState("");

  return (
    <div className="Login-page">
      <div className="row">
        <div className="column">
          <input type="text"
            placeholder="Game Name"
            value={gameName}
            onChange={(e) => setGameName(e.target.value)} />
        </div>
      </div>
      <div className="row">
        <div className="column">
          <input type="text"
            placeholder="Username"
            value={name}
            onChange={(e) => setName(e.target.value)} />
        </div>
        <div className="column">
          <button onClick={() => ch_login(name, gameName)}>
            Login
        </button>
        </div>
      </div>
    </div>
  );
}

function Setup() {
  const [playerType, setPlayerType] = useState("observer");
  const [ready, setReady] = useState(false);

  function setAndSendPlayerType(type) {
    setPlayerType(type);
    ch_set_player_type(type);
    if (type === "observer" && ready) {
      setAndSendReady(false);
    }
  }

  function setAndSendReady(r) {
    setReady(r);
    ch_ready_up(r);
  }

  return (
    <div className="Setup-page">
      <div className="row">
        <div className="column">
          <label>Choose a role: </label>
          <select name="role" id="role" onChange={(e) => setAndSendPlayerType(e.target.value)}>
            <option value="player">Player</option>
            <option value="observer" selected>Observer</option>
          </select>
          {playerType === "player" &&
            <div>
              <label>Ready up</label>
              <input type="checkbox" onChange={(e) => setAndSendReady(!ready)}>
              </input>
            </div>}
        </div>
      </div>
    </div>
  );
}

export default Bulls;
