import React, { useState, useEffect } from 'react';
import { ch_join, ch_push, ch_reset } from './socket';

function Bulls() {
  const [state, setState] = useState({
    history: [],
    guesses: 0,
    invalidGuess: false,
    won: false
  });
  const [guess, setGuess] = useState("");

  let { history, guesses, invalidGuess, won } = state;

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
    setGuess("");
  }

  function printHistory() {
    const items = []

    let c = 1;
    for (const h of history) {
      items.push(
        <tr key={c}>
          <td>{c}</td>
          <td>{h["guess"]}</td>
          <td className="Bull-col">{h["bulls"]}</td>
          <td className="Cow-col">{h["cows"]}</td>
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

  if (won) {
    return (
      <div className="Ending-screen">
        <div>You won!</div>
        <button className="Ending-button" onClick={startNewGame}>Play again?</button>
      </div>
    );
  }

  if (guesses >= 8) {
    return (
      <div className="Ending-screen">
        <div>You lost.</div>
        <button className="Ending-button" onClick={startNewGame}>Play again?</button>
      </div>
    );
  }

  return (
    <div className="Game">
      <div id="History">
        <table id="History-table">
          <thead>
            <tr>
              <th>Attempt</th>
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
      </div>
      {invalidGuess &&
        <div id="Invalid">
          Invalid Entry
      </div>}
    </div>
  );
}

export default Bulls;
