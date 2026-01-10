drop schema public CASCADE;

create schema public;

set
  SEARCH_PATH to public;
-----------------------------------------------------------

-- To show the Lobby:
-- SELECT * FROM games WHERE game_status = 'not started' ORDER BY created_at DESC;

-- To show the Leaderboard:
-- SELECT * FROM leaderboard LIMIT 10;

-- To record a game result (e.g. Player 1 won with 50 points):
-- -- 1. Update the game game_status
-- UPDATE games SET game_status = 'completed', updated_at = NOW() WHERE id = 101;
-- -- 2. Update the winner's stats
-- UPDATE game_player SET score = 50, winner = true WHERE game_id = 101 AND player_id = 1;
-- -- 3. Update the loser's stats
-- UPDATE game_player SET score = 30, winner = false WHERE game_id = 101 AND player_id = 2;

-- 1: User requests login
-- INSERT INTO auth_tokens (token, player_id, expires_at) VALUES ('abc-123-random-string', 1, NOW() + interval '20 minutes');

-- 2: User clicks the link 
-- The link looks like: https://yourgame.com/login?token=abc-123-random-string

-- 3: You verify the token 
-- When the request hits your server, you run a single query to validate everything:
-- SELECT p.* FROM players p
-- JOIN auth_tokens t ON p.id = t.player_id
-- WHERE t.token = 'abc-123-random-string' AND t.expires_at > NOW(); -- Ensure it hasn't expired

-- 4: Cleanup (Crucial!) If the user is successfully found, delete the token immediately so it cannot be used again.
-- DELETE FROM auth_tokens WHERE token = 'abc-123-random-string';


-- A. Generating the Link
--     Generate a long, secure random string (e.g., 32bb4...). This is your Raw Token.
--     In your code, create a SHA-256 hash of that Raw Token.
--     Store the Hash in the database.
--     Email the Raw Token to the user.

-- B. Verifying the Link
--     The user clicks the link: ?token=32bb4....
--     Your app takes that incoming 32bb4... and hashes it using the same SHA-256 logic.
--     Query the DB: SELECT player_id FROM auth_tokens WHERE token_hash = [The New Hash] AND expires_at > NOW();.

-- clean tokens:
-- DELETE FROM auth_tokens WHERE expires_at < NOW();

-- The Lobby Query
-- This query returns all games that haven't started yet, along with the current player count.
-- SELECT 
--     g.id as game_id,
--     g.created_at,
--     COUNT(gp.player_id) as current_players
-- FROM games g
-- LEFT JOIN game_player gp ON g.id = gp.game_id
-- WHERE g.status = 'not started'
-- GROUP BY g.id
-- ORDER BY g.created_at ASC;

-- or

-- SELECT 
--     g.id as game_id,
--     COUNT(gp.player_id) as player_count,
--     -- This creates a comma-separated list of names (e.g., "Alice, Bob")
--     string_agg(p.name, ', ') as players_in_lobby
-- FROM games g
-- LEFT JOIN game_player gp ON g.id = gp.game_id
-- LEFT JOIN players p ON gp.player_id = p.id
-- WHERE g.status = 'not started'
-- GROUP BY g.id
-- -- Optional: Only show games with space (assuming 4 player max)
-- HAVING COUNT(gp.player_id) < 4 
-- ORDER BY g.created_at DESC;

-- CREATE OR REPLACE FUNCTION update_modified_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = NOW();
--     RETURN NEW;
-- END;
-- $$ language 'plpgsql';

-- CREATE TRIGGER update_players_modtime BEFORE UPDATE ON players FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
-- CREATE TRIGGER update_games_modtime BEFORE UPDATE ON games FOR EACH ROW EXECUTE PROCEDURE update_modified_column();


-----------------------------------------------
create table players (
  id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  username TEXT not null,
  email TEXT not null unique,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ not null default NOW(),
  updated_at TIMESTAMPTZ not null default NOW(),
  check (LENGTH(TRIM(username)) BETWEEN 2 AND 30),
  check (LENGTH(TRIM(email)) BETWEEN 5 AND 255)
);

create table auth_tokens (
  token_hash TEXT PRIMARY KEY, 
  player_id INTEGER not null references players (id) on delete CASCADE,
  expires_at TIMESTAMPTZ not null,
  created_at TIMESTAMPTZ not null default NOW()
);

create table games (
  id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  game_status TEXT not null check (game_status in ('not started', 'in progress', 'completed')) default 'not started',
  created_at TIMESTAMPTZ not null default NOW(),
  updated_at TIMESTAMPTZ not null default NOW()
);

create table game_player (
  player_id INTEGER not null references players (id) on delete RESTRICT,
  game_id INTEGER not null references games (id) on delete RESTRICT,
  score INTEGER not null default 0,
  winner BOOLEAN not null default false,
  primary key (player_id, game_id)
);

CREATE OR REPLACE VIEW leaderboard AS
SELECT 
    p.id as player_id,
    p.username,
    COUNT(gp.game_id) as games_played,
    COUNT(CASE WHEN gp.winner THEN 1 END) as wins,
    ROUND(CAST(COUNT(CASE WHEN gp.winner THEN 1 END) AS NUMERIC) / 
          NULLIF(COUNT(gp.game_id), 0) * 100, 2) as win_percentage,
    SUM(gp.score) as total_points,
    ROUND(CAST(SUM(gp.score) AS NUMERIC) / 
          NULLIF(COUNT(gp.game_id), 0), 2) as ppg
FROM players p
JOIN game_player gp ON p.id = gp.player_id
JOIN games g ON gp.game_id = g.id
WHERE g.game_status = 'completed'
GROUP BY p.id, p.username
ORDER BY total_points DESC;


-- OPTIONAL: Indexes for performance
-- Postgres automatically indexes Primary Keys, but you likely need these for lookups:
-- CREATE INDEX idx_players_token ON players(token);
-- CREATE INDEX idx_games_status ON games(game_status);



INSERT INTO players (username, email, last_login) VALUES
('SpeedyGonzales', 'speedy@example.com', NOW()),
('SlowPoke', 'slow@example.com', NOW()),
('BigWinner', 'winner@example.com', NOW()),
('LuckyStrike', 'lucky@example.com', NOW()),
('TokenMaster', 'token@example.com', NOW()),
('NewbieOne', 'new1@example.com', NOW()),
('NewbieTwo', 'new2@example.com', NOW()),
('ProGamer99', 'pro99@example.com', NOW()),
('CasualCat', 'cat@example.com', NOW()),
('DogLover', 'dog@example.com', NOW()),
('MysteryPlayer', 'myst@example.com', NOW()),
('AlphaWolf', 'alpha@example.com', NOW()),
('BetaBear', 'beta@example.com', NOW()),
('GammaGoose', 'gamma@example.com', NOW()),
('DeltaDuck', 'delta@example.com', NOW()),
('OmegaOwl', 'omega@example.com', NOW()),
('ZetaZebra', 'zeta@example.com', NOW()),
('EtaEagle', 'eta@example.com', NOW()),
('ThetaTiger', 'theta@example.com', NOW()),
('IotaIguana', 'iota@example.com', NOW()),
('KappaKangaroo', 'kappa@example.com', NOW()),
('LambdaLion', 'lambda@example.com', NOW());

INSERT INTO games (game_status, created_at) VALUES
-- Games 1-5: The Lobby (Not Started)
('not started', NOW()),
('not started', NOW()),
('not started', NOW()),
('not started', NOW()),
('not started', NOW()),

-- Games 6-10: Currently Playing (In Progress)
('in progress', NOW() - interval '10 minutes'),
('in progress', NOW() - interval '15 minutes'),
('in progress', NOW() - interval '20 minutes'),
('in progress', NOW() - interval '5 minutes'),
('in progress', NOW() - interval '30 minutes'),

-- Games 11-15: History (Completed)
('completed', NOW() - interval '1 day'),
('completed', NOW() - interval '2 days'),
('completed', NOW() - interval '3 days'),
('completed', NOW() - interval '4 days'),
('completed', NOW() - interval '5 days');

-- Game 1 (Full House: 8 players)
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(1, 1, 0, false), (2, 1, 0, false), (3, 1, 0, false), (4, 1, 0, false),
(5, 1, 0, false), (6, 1, 0, false), (7, 1, 0, false), (8, 1, 0, false);

-- Game 2 (Minimum: 3 players)
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(9, 2, 0, false), (10, 2, 0, false), (11, 2, 0, false);

-- Game 3 (Medium: 5 players)
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(12, 3, 0, false), (13, 3, 0, false), (14, 3, 0, false), (15, 3, 0, false), (16, 3, 0, false);

-- Games 4 & 5 left empty intentionally to test empty room logic

-- Game 6: Nail biter! Player 1 is about to win with 24 points.
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(1, 6, 24, false), (2, 6, 20, false), (3, 6, 15, false);

-- Game 7: Just started
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(4, 7, 5, false), (5, 7, 2, false), (6, 7, 8, false), (7, 7, 3, false);

-- Game 8: Mid-game
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(8, 8, 12, false), (9, 8, 14, false), (10, 8, 10, false);

-- Game 9
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(11, 9, 18, false), (12, 9, 19, false), (13, 9, 15, false);

-- Game 10
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(14, 10, 22, false), (15, 10, 21, false), (16, 10, 10, false), (17, 10, 5, false);

-- Game 11: 'BigWinner' (id=3) wins
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(3, 11, 25, true),  
(1, 11, 20, false),
(2, 11, 18, false),
(4, 11, 10, false);

-- Game 12: 'SpeedyGonzales' (id=1) wins
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(1, 12, 27, true),  -- Score can be > 25
(5, 12, 24, false), 
(6, 12, 12, false);

-- Game 13: 'ProGamer99' (id=8) wins
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(8, 13, 25, true), 
(7, 13, 15, false),
(9, 13, 5, false),
(10, 13, 20, false),
(11, 13, 22, false);

-- Game 14: 'BigWinner' (id=3) wins again! (Testing multiple wins for one player)
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(3, 14, 25, true), 
(12, 14, 2, false),
(13, 14, 8, false);

-- Game 15: 'AlphaWolf' (id=12) wins
INSERT INTO game_player (player_id, game_id, score, winner) VALUES
(12, 15, 26, true), 
(3, 15, 23, false), -- BigWinner lost this one
(14, 15, 19, false),
(15, 15, 15, false);





