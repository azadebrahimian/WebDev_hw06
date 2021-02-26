import React, { useState, useEffect } from 'react';
import {
  ch_login, ch_join, ch_push, ch_reset,
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
    previousWinners: [],
    roundEndTime: "",
    roundStartTime: ""
  });
  const [guess, setGuess] = useState("");
  const [recentGuess, setRecentGuess] = useState("")

  let { history, guesses, invalidGuess, won,
    name, gameName, playersReady, ready, playerType,
    totalPlayers, totalReadies, userList, previousWinners,
    roundEndTime, roundStartTime } = state;


  const [time, setTime] = React.useState(0);

  useEffect(() => {
    ch_join(setState);
    const timer = setInterval(() => {
      setTime(prevTime => prevTime + 1); // <-- Change this line!
    }, 1000);
    return () => {
      clearInterval(timer);
    };
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

  function startNewGame() {
    ch_reset();
    setGuess("");
  }

  if (state.name === "" || state.gameName === "") {
    return (
      <Login />
    );
  }

  if (!state.playersReady) {
    return (
      <div>
        <Setup state={state} />
        <p>Previous Winners: {previousWinners}</p>
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

  // if (!state.playersReady) {
  //   return (
  //     <Setup state={state} />
  //   );
  // }

  // if (guesses >= 9) {
  //   return (
  //     <div className="Ending-screen">
  //       <div>You lost.</div>
  //       <button className="Ending-button" onClick={startNewGame}>Play again?</button>
  //     </div>
  //   );
  // }

  function calculateTime(start, end) {
    let sd = new Date(start);
    let ed = new Date(end);
    let cd = new Date();
    let diff1 = sd - cd;
    let diff2 = ed - cd;
    return diff2 - diff1;
  }

  return (
    <div className="Game">
      {/* <p>Time: {subtractTime(roundEndTime)}</p> */}
      <p>Time: {calculateTime(roundStartTime, roundEndTime)}</p>
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
          <button className="Base-button" onClick={startNewGame}>
            Restart!
        </button>
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
          <p>Current Guess: {recentGuess}</p>
        </div>}
      {/* {invalidGuess &&
        <div id="Invalid">
          Invalid Entry
      </div>} */}
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
