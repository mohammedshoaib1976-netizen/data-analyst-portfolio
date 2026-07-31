/* ============================================================
   PROJECT 4: IPL DATASET (Cricket Analytics)
   Tables: Teams, Players, Matches, BattingScores, BowlingFigures
   Business questions: Runs, Wickets, Orange Cap, Winning %
   Skills demonstrated: JOINs, aggregate functions, window
   functions, CTEs, CASE
   ============================================================ */

-- ---------- SCHEMA ----------
DROP TABLE IF EXISTS BowlingFigures;
DROP TABLE IF EXISTS BattingScores;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Teams;

CREATE TABLE Teams (
    team_id     INTEGER PRIMARY KEY,
    team_name   TEXT NOT NULL
);

CREATE TABLE Players (
    player_id   INTEGER PRIMARY KEY,
    player_name TEXT NOT NULL,
    team_id     INTEGER,
    role        TEXT CHECK (role IN ('Batsman','Bowler','All-Rounder','Wicket-Keeper')),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Matches (
    match_id    INTEGER PRIMARY KEY,
    match_date  DATE,
    team1_id    INTEGER,
    team2_id    INTEGER,
    winner_id   INTEGER,
    venue       TEXT,
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id),
    FOREIGN KEY (winner_id) REFERENCES Teams(team_id)
);

CREATE TABLE BattingScores (
    score_id    INTEGER PRIMARY KEY,
    match_id    INTEGER NOT NULL,
    player_id   INTEGER NOT NULL,
    runs        INTEGER,
    balls_faced INTEGER,
    fours       INTEGER,
    sixes       INTEGER,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

CREATE TABLE BowlingFigures (
    figure_id   INTEGER PRIMARY KEY,
    match_id    INTEGER NOT NULL,
    player_id   INTEGER NOT NULL,
    overs       REAL,
    runs_conceded INTEGER,
    wickets     INTEGER,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- ---------- SAMPLE DATA ----------
INSERT INTO Teams (team_id, team_name) VALUES
(1, 'Mumbai Chargers'), (2, 'Chennai Kings'), (3, 'Bengaluru Strikers'),
(4, 'Delhi Warriors'), (5, 'Kolkata Riders'), (6, 'Punjab Lions');

INSERT INTO Players (player_id, player_name, team_id, role) VALUES
(1, 'R. Sharma', 1, 'Batsman'), (2, 'J. Bumrah', 1, 'Bowler'),
(3, 'M. Dhoni', 2, 'Wicket-Keeper'), (4, 'R. Jadeja', 2, 'All-Rounder'),
(5, 'V. Kohli', 3, 'Batsman'), (6, 'M. Siraj', 3, 'Bowler'),
(7, 'R. Pant', 4, 'Wicket-Keeper'), (8, 'A. Axar', 4, 'All-Rounder'),
(9, 'S. Iyer', 5, 'Batsman'), (10, 'A. Russell', 5, 'All-Rounder'),
(11, 'S. Dhawan', 6, 'Batsman'), (12, 'K. Rabada', 6, 'Bowler');

INSERT INTO Matches (match_id, match_date, team1_id, team2_id, winner_id, venue) VALUES
(1, '2026-03-22', 1, 2, 1, 'Wankhede Stadium'),
(2, '2026-03-24', 3, 4, 3, 'Chinnaswamy Stadium'),
(3, '2026-03-26', 5, 6, 6, 'Eden Gardens'),
(4, '2026-03-28', 1, 3, 3, 'Wankhede Stadium'),
(5, '2026-03-30', 2, 4, 2, 'Chepauk Stadium'),
(6, '2026-04-01', 5, 1, 1, 'Eden Gardens'),
(7, '2026-04-03', 6, 3, 3, 'IS Bindra Stadium'),
(8, '2026-04-05', 2, 5, 2, 'Chepauk Stadium'),
(9, '2026-04-07', 4, 6, 4, 'Arun Jaitley Stadium'),
(10, '2026-04-09', 1, 4, 1, 'Wankhede Stadium');

INSERT INTO BattingScores (score_id, match_id, player_id, runs, balls_faced, fours, sixes) VALUES
(1, 1, 1, 78, 45, 8, 3), (2, 1, 3, 34, 28, 2, 1),
(3, 2, 5, 92, 52, 9, 4), (4, 2, 7, 41, 30, 3, 2),
(5, 3, 11, 55, 38, 6, 1), (6, 3, 9, 63, 40, 5, 3),
(7, 4, 1, 45, 32, 4, 1), (8, 4, 5, 88, 50, 7, 5),
(9, 5, 3, 71, 48, 6, 2), (10, 5, 7, 29, 25, 2, 0),
(11, 6, 9, 38, 30, 3, 1), (12, 6, 1, 102, 58, 10, 6),
(13, 7, 11, 47, 35, 4, 1), (14, 7, 5, 65, 42, 6, 2),
(15, 8, 3, 59, 40, 5, 2), (16, 8, 9, 33, 28, 3, 0),
(17, 9, 7, 74, 46, 7, 3), (18, 9, 11, 22, 20, 2, 0),
(19, 10, 1, 61, 39, 5, 2), (20, 10, 7, 48, 33, 4, 1);

INSERT INTO BowlingFigures (figure_id, match_id, player_id, overs, runs_conceded, wickets) VALUES
(1, 1, 2, 4.0, 28, 3), (2, 1, 4, 4.0, 35, 1),
(3, 2, 6, 4.0, 22, 4), (4, 2, 8, 4.0, 40, 0),
(5, 3, 12, 4.0, 31, 2), (6, 3, 10, 3.0, 38, 1),
(7, 4, 6, 4.0, 19, 3), (8, 4, 2, 4.0, 45, 0),
(9, 5, 4, 4.0, 26, 2), (10, 5, 8, 4.0, 33, 1),
(11, 6, 2, 4.0, 21, 4), (12, 6, 10, 4.0, 48, 0),
(13, 7, 6, 4.0, 24, 2), (14, 7, 12, 3.0, 36, 1),
(15, 8, 4, 4.0, 29, 3), (16, 8, 10, 4.0, 41, 1),
(17, 9, 8, 4.0, 18, 3), (18, 9, 12, 4.0, 44, 0),
(19, 10, 2, 4.0, 25, 2), (20, 10, 8, 4.0, 37, 1);

/* ============================================================
   ANALYSIS QUERIES
   ============================================================ */

-- Q1: Orange Cap race - total runs per player across the season
SELECT
    p.player_name,
    t.team_name,
    SUM(b.runs) AS total_runs,
    COUNT(b.score_id) AS innings_played,
    ROUND(AVG(b.runs), 1) AS batting_average,
    MAX(b.runs) AS highest_score
FROM BattingScores b
JOIN Players p ON b.player_id = p.player_id
JOIN Teams t ON p.team_id = t.team_id
GROUP BY p.player_id
ORDER BY total_runs DESC
LIMIT 1;

-- Q2: Full Orange Cap leaderboard (top run scorers, ranked)
SELECT
    RANK() OVER (ORDER BY SUM(b.runs) DESC) AS rank,
    p.player_name,
    t.team_name,
    SUM(b.runs) AS total_runs,
    SUM(b.sixes) AS total_sixes,
    SUM(b.fours) AS total_fours
FROM BattingScores b
JOIN Players p ON b.player_id = p.player_id
JOIN Teams t ON p.team_id = t.team_id
GROUP BY p.player_id
ORDER BY total_runs DESC;

-- Q3: Purple Cap race - total wickets per player
SELECT
    RANK() OVER (ORDER BY SUM(f.wickets) DESC) AS rank,
    p.player_name,
    t.team_name,
    SUM(f.wickets) AS total_wickets,
    ROUND(SUM(f.runs_conceded) * 1.0 / NULLIF(SUM(f.overs), 0), 2) AS economy_rate
FROM BowlingFigures f
JOIN Players p ON f.player_id = p.player_id
JOIN Teams t ON p.team_id = t.team_id
GROUP BY p.player_id
ORDER BY total_wickets DESC;

-- Q4: Team winning percentage
WITH TeamMatches AS (
    SELECT team1_id AS team_id, match_id FROM Matches
    UNION ALL
    SELECT team2_id AS team_id, match_id FROM Matches
)
SELECT
    t.team_name,
    COUNT(tm.match_id) AS matches_played,
    SUM(CASE WHEN m.winner_id = t.team_id THEN 1 ELSE 0 END) AS matches_won,
    ROUND(100.0 * SUM(CASE WHEN m.winner_id = t.team_id THEN 1 ELSE 0 END) / COUNT(tm.match_id), 1) AS win_pct
FROM Teams t
JOIN TeamMatches tm ON t.team_id = tm.team_id
JOIN Matches m ON tm.match_id = m.match_id
GROUP BY t.team_id
ORDER BY win_pct DESC;

-- Q5: Player of the Match candidates - best batting + bowling performance per match (JOIN)
SELECT
    m.match_id,
    m.venue,
    p.player_name AS top_scorer,
    b.runs AS runs_scored
FROM Matches m
JOIN BattingScores b ON m.match_id = b.match_id
JOIN Players p ON b.player_id = p.player_id
WHERE b.runs = (
    SELECT MAX(b2.runs) FROM BattingScores b2 WHERE b2.match_id = m.match_id
)
ORDER BY m.match_id;

-- Q6: Centuries and half-centuries count per player (CASE + aggregate)
SELECT
    p.player_name,
    SUM(CASE WHEN b.runs >= 100 THEN 1 ELSE 0 END) AS centuries,
    SUM(CASE WHEN b.runs >= 50 AND b.runs < 100 THEN 1 ELSE 0 END) AS half_centuries
FROM BattingScores b
JOIN Players p ON b.player_id = p.player_id
GROUP BY p.player_id
HAVING centuries > 0 OR half_centuries > 0
ORDER BY centuries DESC, half_centuries DESC;

-- Q7: Best strike rate among players with at least 2 innings (subquery + HAVING)
SELECT
    p.player_name,
    COUNT(b.score_id) AS innings,
    SUM(b.runs) AS total_runs,
    SUM(b.balls_faced) AS total_balls,
    ROUND(100.0 * SUM(b.runs) / SUM(b.balls_faced), 1) AS strike_rate
FROM BattingScores b
JOIN Players p ON b.player_id = p.player_id
GROUP BY p.player_id
HAVING COUNT(b.score_id) >= 2
ORDER BY strike_rate DESC;

-- Q8: Best bowling figures in a single match (top 3)
SELECT
    p.player_name,
    m.match_id,
    m.venue,
    f.wickets,
    f.runs_conceded
FROM BowlingFigures f
JOIN Players p ON f.player_id = p.player_id
JOIN Matches m ON f.match_id = m.match_id
ORDER BY f.wickets DESC, f.runs_conceded ASC
LIMIT 3;

-- Q9: All-rounders who both scored 40+ runs and took 2+ wickets in the same match
SELECT
    p.player_name,
    m.match_id,
    b.runs,
    f.wickets
FROM Players p
JOIN BattingScores b ON p.player_id = b.player_id
JOIN BowlingFigures f ON p.player_id = f.player_id AND b.match_id = f.match_id
JOIN Matches m ON b.match_id = m.match_id
WHERE b.runs >= 40 AND f.wickets >= 2;

-- Q10: Points table style summary (matches played, won, lost, win %) sorted like a standings table
WITH TeamMatches AS (
    SELECT team1_id AS team_id, match_id FROM Matches
    UNION ALL
    SELECT team2_id AS team_id, match_id FROM Matches
)
SELECT
    t.team_name,
    COUNT(tm.match_id) AS played,
    SUM(CASE WHEN m.winner_id = t.team_id THEN 1 ELSE 0 END) AS won,
    COUNT(tm.match_id) - SUM(CASE WHEN m.winner_id = t.team_id THEN 1 ELSE 0 END) AS lost,
    SUM(CASE WHEN m.winner_id = t.team_id THEN 2 ELSE 0 END) AS points
FROM Teams t
JOIN TeamMatches tm ON t.team_id = tm.team_id
JOIN Matches m ON tm.match_id = m.match_id
GROUP BY t.team_id
ORDER BY points DESC, won DESC;
