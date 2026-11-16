-- MySQL schema generated from ERD (MySQL 8.0+, InnoDB)

CREATE TABLE `User` (
    user_id          INT AUTO_INCREMENT PRIMARY KEY,
    email            VARCHAR(255) NOT NULL UNIQUE,
    username         VARCHAR(100) NOT NULL UNIQUE,
    hashed_password  VARCHAR(255) NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Developer (
    developer_id     INT AUTO_INCREMENT PRIMARY KEY,
    email            VARCHAR(255) NOT NULL UNIQUE,
    username         VARCHAR(100) NOT NULL UNIQUE,
    hashed_password  VARCHAR(255) NOT NULL,
    payout_account   VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE Game (
    game_id          INT AUTO_INCREMENT PRIMARY KEY,
    developer_id     INT NOT NULL,
    name             VARCHAR(255) NOT NULL,
    current_price    INT NOT NULL DEFAULT 0,
    description      TEXT,
    cover_art        VARCHAR(500),
    icon             VARCHAR(500),
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_game_developer (developer_id),
    CONSTRAINT fk_game_developer
        FOREIGN KEY (developer_id) REFERENCES Developer (developer_id)
) ENGINE=InnoDB;

CREATE TABLE GameBuild (
    gbuilds_id       INT AUTO_INCREMENT PRIMARY KEY,
    game_id          INT NOT NULL,
    version          VARCHAR(50) NOT NULL,
    file_url         VARCHAR(500) NOT NULL,
    platform_target  VARCHAR(50) NOT NULL,
    INDEX idx_gamebuild_game (game_id),
    CONSTRAINT fk_gamebuild_game
        FOREIGN KEY (game_id) REFERENCES Game (game_id)
) ENGINE=InnoDB;

CREATE TABLE `Transaction` (
    transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id          INT NOT NULL,
    total_price      INT NOT NULL,
    status           ENUM('Success', 'In Progress', 'Failed') NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_transaction_user (user_id),
    CONSTRAINT fk_transaction_user
        FOREIGN KEY (user_id) REFERENCES `User` (user_id)
) ENGINE=InnoDB;

CREATE TABLE TransactionItem (
    transaction_id   INT NOT NULL,
    game_id          INT NOT NULL,
    game_price       INT NOT NULL,
    PRIMARY KEY (transaction_id, game_id),
    INDEX idx_titem_game (game_id),
    CONSTRAINT fk_titem_transaction
        FOREIGN KEY (transaction_id) REFERENCES `Transaction` (transaction_id),
    CONSTRAINT fk_titem_game
        FOREIGN KEY (game_id) REFERENCES Game (game_id)
) ENGINE=InnoDB;

CREATE TABLE Payment (
    payment_id          INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id      INT NOT NULL,
    acquisition_method  ENUM('Purchase', 'Redeem Code', 'Gift', 'Free Promo') NOT NULL,
    amount              INT NOT NULL,
    provider            VARCHAR(100),
    status              VARCHAR(50) NOT NULL,
    INDEX idx_payment_transaction (transaction_id),
    CONSTRAINT fk_payment_transaction
        FOREIGN KEY (transaction_id) REFERENCES `Transaction` (transaction_id)
) ENGINE=InnoDB;

CREATE TABLE LibraryItem (
    user_id          INT NOT NULL,
    game_id          INT NOT NULL,
    transaction_id   INT NULL,  -- optional: e.g. free/gifted items
    acquired_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    platform_owned   VARCHAR(50),
    PRIMARY KEY (user_id, game_id),
    INDEX idx_library_game (game_id),
    INDEX idx_library_transaction (transaction_id),
    CONSTRAINT fk_library_user
        FOREIGN KEY (user_id) REFERENCES `User` (user_id),
    CONSTRAINT fk_library_game
        FOREIGN KEY (game_id) REFERENCES Game (game_id),
    CONSTRAINT fk_library_transaction
        FOREIGN KEY (transaction_id) REFERENCES `Transaction` (transaction_id)
) ENGINE=InnoDB;
