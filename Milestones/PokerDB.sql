/* DB Schema for 667 Term Project - Revised */
DROP DATABASE IF EXISTS pokerDB;
CREATE DATABASE pokerDB;

DROP TABLE IF EXISTS players CASCADE;
CREATE TABLE players
(
    pid        SERIAL PRIMARY KEY,
    name       varchar(50) UNIQUE  NOT NULL,
    password   varchar(72)         NOT NULL,
    email      varchar(100) UNIQUE NOT NULL,
    chips      INT       DEFAULT 1000 CHECK (chips >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS cards CASCADE;
CREATE TABLE cards
(
    card_id SERIAL PRIMARY KEY,
    rank    VARCHAR(2) NOT NULL,
    suit    VARCHAR(8) NOT NULL,
    UNIQUE (rank, suit)
);

DROP TABLE IF EXISTS games CASCADE;
CREATE TABLE games
(
    game_id     SERIAL PRIMARY KEY,
    max_players SMALLINT    DEFAULT 2 CHECK (max_players BETWEEN 2 AND 6),
    status      VARCHAR(15) DEFAULT 'waiting',
    started_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    ended_at    TIMESTAMP
);

DROP TABLE IF EXISTS game_players CASCADE;
CREATE TABLE game_players
(
    game_id   INT NOT NULL REFERENCES games (game_id) ON DELETE CASCADE,
    player_id INT NOT NULL REFERENCES players (pid) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at   TIMESTAMP,
    PRIMARY KEY (game_id, player_id)
);

DROP TABLE IF EXISTS hands CASCADE;
CREATE TABLE hands
(
    hand_id           SERIAL PRIMARY KEY,
    game_id           INT NOT NULL REFERENCES games (game_id) ON DELETE CASCADE,
    hand_number       SMALLINT NOT NULL CHECK (hand_number > 0),
    pot_amount        INT       DEFAULT 0,
    winning_player_id INT REFERENCES players (pid),
    winning_hand      VARCHAR(20),
    played_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (game_id, hand_number)
);

DROP TABLE IF EXISTS hand_player CASCADE;
CREATE TABLE hand_player
(
    hand_id   INT NOT NULL REFERENCES hands (hand_id) ON DELETE CASCADE,
    player_id INT NOT NULL REFERENCES players (pid) ON DELETE CASCADE,
    chips_bet INT DEFAULT 0,
    chips_won INT DEFAULT 0,
    PRIMARY KEY (hand_id, player_id)
);

DROP TABLE IF EXISTS player_cards CASCADE;
CREATE TABLE player_cards
(
    hand_id    INT      NOT NULL REFERENCES hands (hand_id) ON DELETE CASCADE,
    player_id  INT      NOT NULL REFERENCES players (pid) ON DELETE CASCADE,
    card_id    INT      NOT NULL REFERENCES cards (card_id),
    card_order SMALLINT NOT NULL CHECK (card_order IN (1, 2)),
    PRIMARY KEY (hand_id, player_id, card_order)
);

DROP TABLE IF EXISTS house_cards CASCADE;
CREATE TABLE house_cards
(
    hand_id    INT      NOT NULL REFERENCES hands (hand_id) ON DELETE CASCADE,
    card_id    INT      NOT NULL REFERENCES cards (card_id),
    card_order SMALLINT NOT NULL CHECK (card_order BETWEEN 1 AND 5),
    PRIMARY KEY (hand_id, card_order)
);

DROP TABLE IF EXISTS chip_transactions CASCADE;
CREATE TABLE chip_transactions
(
    transaction_id SERIAL PRIMARY KEY,
    player_id      INT NOT NULL REFERENCES players (pid) ON DELETE CASCADE,
    hand_id        INT REFERENCES hands (hand_id) ON DELETE SET NULL,
    amount         INT NOT NULL,
    balance_after  INT NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS chat CASCADE;
CREATE TABLE chat
(
    message_id SERIAL PRIMARY KEY,
    player_id  INT  NOT NULL REFERENCES players (pid) ON DELETE CASCADE,
    message    TEXT NOT NULL,
    sent_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);