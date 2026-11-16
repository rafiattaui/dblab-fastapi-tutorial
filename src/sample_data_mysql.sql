-- Sample data for the MySQL schema (run schema_mysql.sql first)
-- Prices are whole numbers (e.g. IDR). Passwords are dummy placeholder hashes.

-- ------------------------------------------------------------
-- Users
-- ------------------------------------------------------------
INSERT INTO `User` (user_id, email, username, hashed_password, created_at) VALUES
(1, 'alice@example.com', 'alice',  '$2b$12$dummyhashalice000000000000000000000000000000000000000', '2026-01-10 09:15:00'),
(2, 'bob@example.com',   'bob',    '$2b$12$dummyhashbob00000000000000000000000000000000000000000', '2026-02-03 14:20:00'),
(3, 'citra@example.com', 'citra',  '$2b$12$dummyhashcitra000000000000000000000000000000000000000', '2026-03-18 18:45:00'),
(4, 'dimas@example.com', 'dimas',  '$2b$12$dummyhashdimas000000000000000000000000000000000000000', '2026-04-22 11:05:00'),
(5, 'eka@example.com',   'eka',    '$2b$12$dummyhasheka0000000000000000000000000000000000000000', '2026-05-30 20:30:00');

-- ------------------------------------------------------------
-- Developers
-- ------------------------------------------------------------
INSERT INTO Developer (developer_id, email, username, hashed_password, payout_account) VALUES
(1, 'contact@pixelforge.dev',  'pixelforge',  '$2b$12$dummyhashdev1000000000000000000000000000000000000000', 'BCA-1234567890'),
(2, 'hello@nightowlgames.dev', 'nightowl',    '$2b$12$dummyhashdev2000000000000000000000000000000000000000', 'Mandiri-9876543210'),
(3, 'team@greenleaf.dev',      'greenleaf',   '$2b$12$dummyhashdev3000000000000000000000000000000000000000', 'PayPal-greenleaf@example.com');

-- ------------------------------------------------------------
-- Games
-- ------------------------------------------------------------
INSERT INTO Game (game_id, developer_id, name, current_price, description, cover_art, icon, created_at) VALUES
(1, 1, 'Pixel Quest',        150000, 'A retro platformer adventure through handcrafted pixel worlds.',   'https://cdn.example.com/games/1/cover.jpg', 'https://cdn.example.com/games/1/icon.png', '2025-06-01 10:00:00'),
(2, 1, 'Starfall Odyssey',   250000, 'An epic space exploration RPG with a branching story.',            'https://cdn.example.com/games/2/cover.jpg', 'https://cdn.example.com/games/2/icon.png', '2025-09-15 10:00:00'),
(3, 2, 'Neon Drift',         120000, 'Fast-paced arcade racing set in a neon-soaked city.',              'https://cdn.example.com/games/3/cover.jpg', 'https://cdn.example.com/games/3/icon.png', '2025-11-20 10:00:00'),
(4, 2, 'Dungeon Keepers',    180000, 'Build, defend and manage your own dungeon in this strategy game.', 'https://cdn.example.com/games/4/cover.jpg', 'https://cdn.example.com/games/4/icon.png', '2026-01-05 10:00:00'),
(5, 3, 'Farm Valley Tales',   90000, 'A cozy farming sim with seasons, festivals and friendly villagers.', 'https://cdn.example.com/games/5/cover.jpg', 'https://cdn.example.com/games/5/icon.png', '2026-02-14 10:00:00'),
(6, 3, 'Cosmic Arena',            0, 'Free-to-play multiplayer arena shooter.',                          'https://cdn.example.com/games/6/cover.jpg', 'https://cdn.example.com/games/6/icon.png', '2026-03-01 10:00:00');

-- ------------------------------------------------------------
-- Game builds
-- ------------------------------------------------------------
INSERT INTO GameBuild (gbuilds_id, game_id, version, file_url, platform_target) VALUES
(1,  1, '1.0.0', 'https://files.example.com/builds/pixel-quest-1.0.0-win.zip',      'windows'),
(2,  1, '1.0.0', 'https://files.example.com/builds/pixel-quest-1.0.0-linux.tar.gz', 'linux'),
(3,  1, '1.1.0', 'https://files.example.com/builds/pixel-quest-1.1.0-win.zip',      'windows'),
(4,  2, '2.0.0', 'https://files.example.com/builds/starfall-2.0.0-win.zip',         'windows'),
(5,  2, '2.0.0', 'https://files.example.com/builds/starfall-2.0.0-mac.dmg',         'macos'),
(6,  3, '1.2.3', 'https://files.example.com/builds/neon-drift-1.2.3-win.zip',       'windows'),
(7,  4, '0.9.5', 'https://files.example.com/builds/dungeon-keepers-0.9.5-win.zip',  'windows'),
(8,  5, '1.0.1', 'https://files.example.com/builds/farm-valley-1.0.1-win.zip',      'windows'),
(9,  5, '1.0.1', 'https://files.example.com/builds/farm-valley-1.0.1-android.apk',  'android'),
(10, 6, '3.4.0', 'https://files.example.com/builds/cosmic-arena-3.4.0-win.zip',     'windows');

-- ------------------------------------------------------------
-- Transactions (total_price = sum of its TransactionItem prices)
-- ------------------------------------------------------------
INSERT INTO `Transaction` (transaction_id, user_id, total_price, status, created_at) VALUES
(1, 1, 400000, 'Success',     '2026-02-01 10:30:00'),  -- alice buys 2 games
(2, 1, 120000, 'Success',     '2026-03-12 19:10:00'),  -- alice buys Neon Drift
(3, 2, 150000, 'Success',     '2026-02-10 08:45:00'),  -- bob buys Pixel Quest
(4, 2, 180000, 'Failed',      '2026-02-11 21:00:00'),  -- bob's payment failed
(5, 3,  90000, 'In Progress', '2026-11-16 19:50:00'),  -- citra, still pending
(6, 3,      0, 'Success',     '2026-03-20 12:00:00'),  -- citra, free promo
(7, 4, 180000, 'Success',     '2026-05-02 16:25:00'),  -- dimas buys Dungeon Keepers
(8, 5,      0, 'Success',     '2026-06-01 09:00:00'),  -- eka, free promo
(9, 2,      0, 'Success',     '2026-07-07 13:40:00');  -- bob redeems a code for Neon Drift

-- ------------------------------------------------------------
-- Transaction items
-- ------------------------------------------------------------
INSERT INTO TransactionItem (transaction_id, game_id, game_price) VALUES
(1, 1, 150000),
(1, 2, 250000),
(2, 3, 120000),
(3, 1, 150000),
(4, 4, 180000),
(5, 5,  90000),
(6, 6,      0),
(7, 4, 180000),
(8, 6,      0),
(9, 3,      0);

-- ------------------------------------------------------------
-- Payments
-- ------------------------------------------------------------
INSERT INTO Payment (payment_id, transaction_id, acquisition_method, amount, provider, status) VALUES
(1, 1, 'Purchase',    400000, 'Midtrans', 'Success'),
(2, 2, 'Purchase',    120000, 'Xendit',   'Success'),
(3, 3, 'Purchase',    150000, 'Midtrans', 'Success'),
(4, 4, 'Purchase',    180000, 'Xendit',   'Failed'),
(5, 5, 'Purchase',     90000, 'Midtrans', 'Pending'),
(6, 6, 'Free Promo',       0, NULL,       'Success'),
(7, 7, 'Purchase',    180000, 'PayPal',   'Success'),
(8, 8, 'Free Promo',       0, NULL,       'Success'),
(9, 9, 'Redeem Code',      0, NULL,       'Success');

-- ------------------------------------------------------------
-- Library items (only for successful acquisitions; one gift has no transaction)
-- ------------------------------------------------------------
INSERT INTO LibraryItem (user_id, game_id, transaction_id, acquired_at, platform_owned) VALUES
(1, 1, 1,    '2026-02-01 10:31:00', 'windows'),
(1, 2, 1,    '2026-02-01 10:31:00', 'windows'),
(1, 3, 2,    '2026-03-12 19:11:00', 'windows'),
(2, 1, 3,    '2026-02-10 08:46:00', 'linux'),
(2, 3, 9,    '2026-07-07 13:41:00', 'windows'),
(3, 6, 6,    '2026-03-20 12:01:00', 'windows'),
(4, 4, 7,    '2026-05-02 16:26:00', 'windows'),
(5, 6, 8,    '2026-06-01 09:01:00', 'android'),
(5, 5, NULL, '2026-08-15 10:00:00', 'android');  -- gifted by developer, no transaction
