import Form from './components/Form';
import KeepAlive from './components/KeepAlive';
import Name from './components/Name';
import Scoreboard from './components/Scoreboard';
import Start from './components/Start';
import Timer from './components/Timer';
import Word from './components/Word';
import UseAppState from './hooks/useAppState';
import { div, h1, winner } from './styles/Index.module.css';

function App() {
  const {
    answered,
    connected,
    dupeName,
    gameHasBegun,
    h1Text,
    hasJoined,
    invalidInput,
    message,
    newWord,
    oldWord,
    pingServer,
    playerColor,
    playerName,
    players,
    send,
    setShowStartButton,
    setSubmitSignal,
    showAnswers,
    showReset,
    showStartButton,
    showStartTimer,
    showSVGTimer,
    showWords,
    submitSignal,
    timer,
    winners,
  } = UseAppState();

  return (
    <main>
      {pingServer && connected && (
        <KeepAlive pingWS={() => message('keepAlive')} />
      )}
      <Name playerName={playerName} />
      <h1 style={{ backgroundColor: playerColor }} className={h1}>
        {h1Text}
      </h1>
      {players.length > 0 && connected && (
        <Scoreboard
          playerName={playerName}
          players={players}
          showAnswers={showAnswers}
          winners={!!winners}
          word={oldWord}
        />
      )}
      {hasJoined && connected && (
        <div className={div}>
          {showStartButton && hasJoined && (
            <Start
              onClick={() => {
                message('start');
                setShowStartButton(false);
              }}
              players={players}
              gameHasBegun={gameHasBegun}
            />
          )}
          {showStartTimer && timer > 0 && <Timer timer={timer} />}
          {showWords && hasJoined && !winners && (
            <Word
              onAnimationEnd={() => setSubmitSignal(true)}
              playerColor={playerColor}
              showAnswers={showAnswers}
              showSVGTimer={showSVGTimer}
              word={newWord}
            />
          )}
          {winners && (
            <p aria-live="assertive" role="alert" className={winner}>
              {winners} {winners.includes(' and ') ? 'Win!!' : 'Wins!!'}
            </p>
          )}
          {showReset && (
            <button type="button" onClick={() => message('reset')}>
              Play Again
            </button>
          )}
        </div>
      )}
      {connected && !winners && (
        <Form
          answered={answered}
          dupeName={dupeName}
          hasJoined={hasJoined}
          invalidInput={invalidInput}
          onEnter={(val) => send(val)}
          playerName={playerName}
          playing={!!newWord}
          submitSignal={submitSignal}
        />
      )}
      {!connected && (
        <p style={{ fontSize: '18px' }}>
          Server not available. Please try again.
        </p>
      )}
      <footer>
        <a
          rel="noopener noreferrer"
          target="_blank"
          href="https://github.com/jamessouth/clean-tablet"
        >
          <svg fill="#f5f5f5" aria-hidden="true" viewBox="0 0 24 24">
            <path d="M12 1C5.923 1 1 5.923 1 12c0 4.867 3.149 8.979 7.521 10.436.55.096.756-.233.756-.522 0-.262-.013-1.128-.013-2.049-2.764.509-3.479-.674-3.699-1.292-.124-.317-.66-1.293-1.127-1.554-.385-.207-.936-.715-.014-.729.866-.014 1.485.797 1.691 1.128.99 1.663 2.571 1.196 3.204.907.096-.715.385-1.196.701-1.471-2.448-.275-5.005-1.224-5.005-5.432 0-1.196.426-2.186 1.128-2.956-.111-.275-.496-1.402.11-2.915 0 0 .921-.288 3.024 1.128a10.2 10.2 0 0 1 2.75-.371c.936 0 1.871.123 2.75.371 2.104-1.43 3.025-1.128 3.025-1.128.605 1.513.221 2.64.111 2.915.701.77 1.127 1.747 1.127 2.956 0 4.222-2.571 5.157-5.019 5.432.399.344.743 1.004.743 2.035 0 1.471-.014 2.654-.014 3.025 0 .289.206.632.756.522C19.851 20.979 23 16.854 23 12c0-6.077-4.922-11-11-11" />
          </svg>
        </a>
      </footer>
    </main>
  );
}

export default App;
