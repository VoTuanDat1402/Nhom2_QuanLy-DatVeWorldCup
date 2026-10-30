-- ============================================================================
-- HỆ THỐNG ĐẶT VÉ FIFA WORLD CUP 2030 (QUY MÔ 100,000 CHỖ NGOÌ/SÂN)
-- Cơ sở dữ liệu đồng bộ 100% với Codebase Laravel (Nhom2_QuanLy-DatVeWorldCup)
-- ============================================================================

DROP DATABASE IF EXISTS worldcup_2030;
CREATE DATABASE worldcup_2030 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE worldcup_2030;

SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- 1. BẢNG NGƯỜI DÙNG (Tương thích User.php)
-- ==========================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    role ENUM('USER', 'ADMIN') DEFAULT 'USER',
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================
-- 2. BẢNG QUỐC GIA ĐĂNG CAI (3 QUỐC GIA)
-- ==========================================
CREATE TABLE host_countries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code CHAR(3) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================
-- 3. BẢNG THÀNH PHỐ TỔ CHỨC (16 THÀNH PHỐ)
-- ==========================================
CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT NOT NULL,
    city_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES host_countries(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================================
-- 4. BẢNG SÂN VẬN ĐỘNG (Tương thích Stadium.php)
-- ==========================================
CREATE TABLE stadiums (
    id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NULL,
    name VARCHAR(150) NOT NULL,
    stadium_name VARCHAR(150) NULL,
    location VARCHAR(255) NULL,
    capacity INT NOT NULL DEFAULT 100000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==========================================
-- 5. BẢNG LOẠI VÉ (TICKET_TYPES)
-- ==========================================
CREATE TABLE ticket_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================
-- 6. BẢNG ĐỘI TUYỂN (Tương thích Team.php)
-- ==========================================
CREATE TABLE teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    team_name VARCHAR(100) NULL,
    code CHAR(3) NOT NULL UNIQUE,
    flag_url VARCHAR(255) NULL,
    group_name ENUM('A','B','C','D','E','F','G','H','I','J','K','L') NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================
-- 7. BẢNG CẦU THỦ (Tương thích Player.php)
-- ==========================================
CREATE TABLE players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    shirt_number INT NULL,
    position ENUM('GK', 'DF', 'MF', 'FW') DEFAULT 'MF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================================
-- 8. BẢNG KHU VỰC GHẾ (Tương thích SeatZone.php)
-- ==========================================
CREATE TABLE seat_zones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stadium_id INT NOT NULL,
    ticket_type_id INT NULL,
    zone_name VARCHAR(50) NOT NULL,
    name VARCHAR(50) NULL,
    type ENUM('VIP', 'STANDARD') NOT NULL DEFAULT 'STANDARD',
    total_seats INT NOT NULL DEFAULT 0,
    base_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stadium_id) REFERENCES stadiums(id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_type_id) REFERENCES ticket_types(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==========================================
-- 9. BẢNG TRẬN ĐẤU (Tương thích MatchGame.php)
-- ==========================================
CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    match_number INT NOT NULL UNIQUE,
    stage ENUM('GROUP', 'ROUND_32', 'ROUND_16', 'QUARTER_FINAL', 'SEMI_FINAL', 'THIRD_PLACE', 'FINAL') NOT NULL,
    stadium_id INT NOT NULL,
    home_team_id INT NULL,
    away_team_id INT NULL,
    match_time DATETIME NOT NULL,
    match_date DATETIME NULL,
    home_score INT DEFAULT 0,
    away_score INT DEFAULT 0,
    status ENUM('UPCOMING', 'LIVE', 'FINISHED', 'CANCELLED') DEFAULT 'UPCOMING',
    match_status ENUM('UPCOMING', 'LIVE', 'FINISHED', 'CANCELLED') DEFAULT 'UPCOMING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stadium_id) REFERENCES stadiums(id) ON DELETE CASCADE,
    FOREIGN KEY (home_team_id) REFERENCES teams(id) ON DELETE SET NULL,
    FOREIGN KEY (away_team_id) REFERENCES teams(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==========================================
-- 10. BẢNG GHẾ THEO TRẬN ĐẤU (Tương thích MatchSeat.php)
-- ==========================================
CREATE TABLE match_seats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    seat_zone_id INT NOT NULL,
    seat_code VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status ENUM('AVAILABLE', 'BOOKED', 'RESERVED', 'HELD') DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (seat_zone_id) REFERENCES seat_zones(id) ON DELETE CASCADE,
    UNIQUE KEY idx_match_seat_code (match_id, seat_code)
) ENGINE=InnoDB;

CREATE INDEX idx_match_seat_status ON match_seats(match_id, status);

-- ==========================================
-- 11. BẢNG ĐƠN HÀNG (Tương thích Order.php)
-- ==========================================
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_code VARCHAR(64) NULL UNIQUE,
    total_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NULL,
    status ENUM('PENDING', 'PAID', 'CANCELLED') DEFAULT 'PENDING',
    payment_status ENUM('PENDING', 'PAID', 'CANCELLED') DEFAULT 'PENDING',
    payment_method VARCHAR(50) DEFAULT 'SIMULATION',
    hold_expires_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_hold_expiry (status, hold_expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================================
-- 12. BẢNG VÉ ĐÃ ĐẶT (Tương thích Ticket.php)
-- ==========================================
CREATE TABLE tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    match_id INT NOT NULL,
    match_seat_id INT NOT NULL,
    ticket_code VARCHAR(64) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status ENUM('BOOKED', 'CANCELLED', 'VALID') DEFAULT 'BOOKED',
    check_in_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (match_seat_id) REFERENCES match_seats(id) ON DELETE CASCADE,
    UNIQUE KEY idx_match_seat_ticket (match_id, match_seat_id),
    INDEX idx_ticket_check_in (ticket_code, status, check_in_at)
) ENGINE=InnoDB;

-- ==========================================
-- 13. BẢNG THANH TOÁN (Tương thích Payment.php & PaymentService)
-- ==========================================
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL DEFAULT 'SIMULATION',
    transaction_id VARCHAR(100) NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- NẠP DỮ LIỆU MẪU (SEED DATA WORLD CUP 2030)
-- ============================================================================

-- 1. LOẠI VÉ
INSERT INTO ticket_types (id, type_name, description) VALUES
(1, 'VIP', 'Vé khán đài VIP, lối đi ưu tiên, kèm đồ ăn nhẹ & đồ uống cao cấp'),
(2, 'STANDARD', 'Vé phổ thông khán đài A/B/C/D');

-- 2. NGƯỜI DÙNG MẪU (Mật khẩu: 123456)
INSERT INTO users (id, name, full_name, email, password, phone, role) VALUES
(1, 'System Admin', 'System Admin', 'admin@worldcup2030.com', '$2y$10$llQ00qB7KL4WTWH0.hhSQuuIJduwpFdIno5t5qYtlxG17u9O9UbA6', '0901234567', 'ADMIN'),
(2, 'Nguyễn Văn A', 'Nguyễn Văn A', 'user@gmail.com', '$2y$10$llQ00qB7KL4WTWH0.hhSQuuIJduwpFdIno5t5qYtlxG17u9O9UbA6', '0987654321', 'USER'),
(3, 'Trần Thị B', 'Trần Thị B', 'user_b@gmail.com', '$2y$10$llQ00qB7KL4WTWH0.hhSQuuIJduwpFdIno5t5qYtlxG17u9O9UbA6', '0912345678', 'USER');

-- 3. QUỐC GIA ĐĂNG CAI
INSERT INTO host_countries (id, country_name, country_code) VALUES
(1, 'Tây Ban Nha', 'ESP'),
(2, 'Bồ Đào Nha', 'POR'),
(3, 'Ma-rốc', 'MAR');

-- 4. THÀNH PHỐ TỔ CHỨC
INSERT INTO cities (id, country_id, city_name) VALUES
(1, 1, 'Madrid'), (2, 1, 'Barcelona'), (3, 1, 'Seville'), (4, 1, 'Bilbao'),
(5, 1, 'San Sebastian'), (6, 1, 'A Coruna'), (7, 1, 'Zaragoza'), (8, 1, 'Malaga'), (9, 1, 'Las Palmas'),
(10, 2, 'Lisbon'), (11, 2, 'Porto'), (12, 2, 'Faro'),
(13, 3, 'Casablanca'), (14, 3, 'Rabat'), (15, 3, 'Tangier'), (16, 3, 'Marrakech');

-- 5. SÂN VẬN ĐỘNG QUY MÔ 100,000 CHỖ
INSERT INTO stadiums (id, city_id, name, stadium_name, location, capacity) VALUES
(1, 1, 'Santiago Bernabeu', 'Santiago Bernabeu', 'Madrid, Spain', 100000),
(2, 2, 'Spotify Camp Nou', 'Spotify Camp Nou', 'Barcelona, Spain', 100000),
(3, 3, 'Estadio La Cartuja', 'Estadio La Cartuja', 'Seville, Spain', 100000),
(4, 4, 'San Mames', 'San Mames', 'Bilbao, Spain', 100000),
(5, 5, 'Reale Arena', 'Reale Arena', 'San Sebastian, Spain', 100000),
(6, 6, 'Estadio Abanca-Riazor', 'Estadio Abanca-Riazor', 'A Coruna, Spain', 100000),
(7, 7, 'Estadio La Romareda', 'Estadio La Romareda', 'Zaragoza, Spain', 100000),
(8, 8, 'Estadio La Rosaleda', 'Estadio La Rosaleda', 'Malaga, Spain', 100000),
(9, 9, 'Estadio Gran Canaria', 'Estadio Gran Canaria', 'Las Palmas, Spain', 100000),
(10, 10, 'Estadio da Luz', 'Estadio da Luz', 'Lisbon, Portugal', 100000),
(11, 11, 'Estadio do Dragao', 'Estadio do Dragao', 'Porto, Portugal', 100000),
(12, 12, 'Estadio Algarve', 'Estadio Algarve', 'Faro, Portugal', 100000),
(13, 13, 'Grand Stade de Casablanca', 'Grand Stade de Casablanca', 'Casablanca, Morocco', 100000),
(14, 14, 'Stade Prince Moulay Abdellah', 'Stade Prince Moulay Abdellah', 'Rabat, Morocco', 100000),
(15, 15, 'Ibn Batouta Stadium', 'Ibn Batouta Stadium', 'Tangier, Morocco', 100000),
(16, 16, 'Grand Stade de Marrakech', 'Grand Stade de Marrakech', 'Marrakech, Morocco', 100000);

-- 6. KHU VỰC GHẾ (LIÊN KẾT TRỰC TIẾP TICKET_TYPE_ID)
INSERT INTO seat_zones (stadium_id, ticket_type_id, zone_name, name, type, total_seats, base_price)
SELECT id, 1, 'Khán đài VIP', 'Khán đài VIP', 'VIP', 10000, 8500000.00 FROM stadiums;

INSERT INTO seat_zones (stadium_id, ticket_type_id, zone_name, name, type, total_seats, base_price)
SELECT id, 2, 'Khán đài Phổ Thông', 'Khán đài Phổ Thông', 'STANDARD', 90000, 2500000.00 FROM stadiums;

-- 7. 48 ĐỘI TUYỂN 12 BẢNG (A - L)
INSERT INTO teams (id, name, team_name, code, group_name) VALUES
(1, 'Tây Ban Nha', 'Tây Ban Nha', 'ESP', 'A'), (2, 'Bồ Đào Nha', 'Bồ Đào Nha', 'POR', 'A'), (3, 'Ma-rốc', 'Ma-rốc', 'MAR', 'A'), (4, 'Séc', 'Séc', 'CZE', 'A'),
(5, 'Nhật Bản', 'Nhật Bản', 'JPN', 'B'), (6, 'Hàn Quốc', 'Hàn Quốc', 'KOR', 'B'), (7, 'Úc', 'Úc', 'AUS', 'B'), (8, 'Ả Rập Xê Út', 'Ả Rập Xê Út', 'KSA', 'B'),
(9, 'Pháp', 'Pháp', 'FRA', 'C'), (10, 'Đức', 'Đức', 'GER', 'C'), (11, 'Ý', 'Ý', 'ITA', 'C'), (12, 'Hà Lan', 'Hà Lan', 'NED', 'C'),
(13, 'Anh', 'Anh', 'ENG', 'D'), (14, 'Bỉ', 'Bỉ', 'BEL', 'D'), (15, 'Kroatia', 'Kroatia', 'CRO', 'D'), (16, 'Thụy Sĩ', 'Thụy Sĩ', 'SUI', 'D'),
(17, 'Brasil', 'Brasil', 'BRA', 'E'), (18, 'Argentina', 'Argentina', 'ARG', 'E'), (19, 'Uruguay', 'Uruguay', 'URU', 'E'), (20, 'Colombia', 'Colombia', 'COL', 'E'),
(21, 'Mỹ', 'Mỹ', 'USA', 'F'), (22, 'Mexico', 'Mexico', 'MEX', 'F'), (23, 'Canada', 'Canada', 'CAN', 'F'), (24, 'Costa Rica', 'Costa Rica', 'CRC', 'F'),
(25, 'Senegal', 'Senegal', 'SEN', 'G'), (26, 'Nigeria', 'Nigeria', 'NGA', 'G'), (27, 'Ai Cập', 'Ai Cập', 'EGY', 'G'), (28, 'Ghana', 'Ghana', 'GHA', 'G'),
(29, 'Đan Mạch', 'Đan Mạch', 'DEN', 'H'), (30, 'Áo', 'Áo', 'AUT', 'H'), (31, 'Ba Lan', 'Ba Lan', 'POL', 'H'), (32, 'Thụy Điển', 'Thụy Điển', 'SWE', 'H'),
(33, 'Ecuador', 'Ecuador', 'ECU', 'I'), (34, 'Chile', 'Chile', 'CHI', 'I'), (35, 'Peru', 'Peru', 'PER', 'I'), (36, 'Paraguay', 'Paraguay', 'PAR', 'I'),
(37, 'Iran', 'Iran', 'IRN', 'J'), (38, 'I-rắc', 'I-rắc', 'IRQ', 'J'), (39, 'Uzbekistan', 'Uzbekistan', 'UZB', 'J'), (40, 'Qatar', 'Qatar', 'QAT', 'J'),
(41, 'Cameroon', 'Cameroon', 'CMR', 'K'), (42, 'Mali', 'Mali', 'MLI', 'K'), (43, 'Bờ Biển Ngà', 'Bờ Biển Ngà', 'CIV', 'K'), (44, 'Tunisia', 'Tunisia', 'TUN', 'K'),
(45, 'Algeria', 'Algeria', 'ALG', 'L'), (46, 'Thổ Nhĩ Kỳ', 'Thổ Nhĩ Kỳ', 'TUR', 'L'), (47, 'Ukraina', 'Ukraina', 'UKR', 'L'), (48, 'Serbia', 'Serbia', 'SRB', 'L');

-- 8. NẠP DỮ LIỆU MẪU CẦU THỦ (PLAYERS)
INSERT INTO players (team_id, name, shirt_number, position) VALUES
-- 1. Tây Ban Nha (ESP)
(1, 'Unai Simón', 23, 'GK'), (1, 'David Raya', 1, 'GK'), (1, 'Dani Carvajal', 2, 'DF'), (1, 'Robin Le Normand', 3, 'DF'), (1, 'Aymeric Laporte', 14, 'DF'), (1, 'Marc Cucurella', 24, 'DF'), (1, 'Alejandro Grimaldo', 12, 'DF'), (1, 'Rodri', 16, 'MF'), (1, 'Pedri', 8, 'MF'), (1, 'Fabián Ruiz', 17, 'MF'), (1, 'Gavi', 9, 'MF'), (1, 'Dani Olmo', 10, 'MF'), (1, 'Mikel Merino', 6, 'MF'), (1, 'Lamine Yamal', 19, 'FW'), (1, 'Nico Williams', 17, 'FW'), (1, 'Álvaro Morata', 7, 'FW'), (1, 'Ferran Torres', 11, 'FW'), (1, 'Mikel Oyarzabal', 21, 'FW'),

-- 2. Bồ Đào Nha (POR)
(2, 'Diogo Costa', 1, 'GK'), (2, 'Rui Patrício', 12, 'GK'), (2, 'Rúben Dias', 4, 'DF'), (2, 'Pepe', 3, 'DF'), (2, 'Nuno Mendes', 19, 'DF'), (2, 'João Cancelo', 20, 'DF'), (2, 'Diogo Dalot', 5, 'DF'), (2, 'Bruno Fernandes', 8, 'MF'), (2, 'Bernardo Silva', 10, 'MF'), (2, 'Vitinha', 23, 'MF'), (2, 'João Palhinha', 6, 'MF'), (2, 'Rúben Neves', 18, 'MF'), (2, 'Cristiano Ronaldo', 7, 'FW'), (2, 'Rafael Leão', 15, 'FW'), (2, 'Diogo Jota', 21, 'FW'), (2, 'João Félix', 11, 'FW'), (2, 'Gonçalo Ramos', 9, 'FW'),

-- 3. Ma-rốc (MAR)
(3, 'Yassine Bounou', 1, 'GK'), (3, 'Munir Mohamedi', 12, 'GK'), (3, 'Achraf Hakimi', 2, 'DF'), (3, 'Noussair Mazraoui', 3, 'DF'), (3, 'Nayef Aguerd', 5, 'DF'), (3, 'Romain Saïss', 6, 'DF'), (3, 'Sofyan Amrabat', 4, 'MF'), (3, 'Azzedine Ounahi', 8, 'MF'), (3, 'Hakim Ziyech', 7, 'MF'), (3, 'Bilal El Khannouss', 23, 'MF'), (3, 'Youssef En-Nesyri', 19, 'FW'), (3, 'Brahim Díaz', 10, 'FW'), (3, 'Soufiane Rahimi', 9, 'FW'), (3, 'Abde Ezzalzouli', 16, 'FW'),

-- 4. Séc (CZE)
(4, 'Jindřich Staněk', 1, 'GK'), (4, 'Matej Kovář', 16, 'GK'), (4, 'Vladimír Coufal', 5, 'DF'), (4, 'Ladislav Krejčí', 4, 'DF'), (4, 'Tomáš Holeš', 3, 'DF'), (4, 'David Zima', 2, 'DF'), (4, 'Tomáš Souček', 22, 'MF'), (4, 'Antonín Barák', 7, 'MF'), (4, 'Lukáš Provod', 14, 'MF'), (4, 'Michal Sadílek', 15, 'MF'), (4, 'Patrik Schick', 10, 'FW'), (4, 'Adam Hložek', 9, 'FW'), (4, 'Mojmír Chytil', 11, 'FW'), (4, 'Jan Kuchta', 13, 'FW'),

-- 5. Nhật Bản (JPN)
(5, 'Zion Suzuki', 1, 'GK'), (5, 'Keisuke Osako', 12, 'GK'), (5, 'Takehiro Tomiyasu', 16, 'DF'), (5, 'Ko Itakura', 4, 'DF'), (5, 'Yuto Nagatomo', 5, 'DF'), (5, 'Koki Machida', 15, 'DF'), (5, 'Wataru Endo', 6, 'MF'), (5, 'Hidemasa Morita', 5, 'MF'), (5, 'Takefusa Kubo', 20, 'MF'), (5, 'Kaoru Mitoma', 7, 'MF'), (5, 'Ritsu Doan', 8, 'MF'), (5, 'Daichi Kamada', 14, 'MF'), (5, 'Ayase Ueda', 9, 'FW'), (5, 'Takumi Minamino', 10, 'FW'), (5, 'Kyogo Furuhashi', 11, 'FW'), (5, 'Daizen Maeda', 13, 'FW'),

-- 6. Hàn Quốc (KOR)
(6, 'Jo Hyeon-woo', 21, 'GK'), (6, 'Song Bum-keun', 1, 'GK'), (6, 'Kim Min-jae', 4, 'DF'), (6, 'Kim Young-gwon', 19, 'DF'), (6, 'Seol Young-woo', 22, 'DF'), (6, 'Kim Jin-su', 3, 'DF'), (6, 'Son Heung-min', 7, 'MF'), (6, 'Lee Kang-in', 18, 'MF'), (6, 'Hwang In-beom', 6, 'MF'), (6, 'Lee Jae-sung', 10, 'MF'), (6, 'Jeong Woo-yeong', 14, 'MF'), (6, 'Hwang Hee-chan', 11, 'FW'), (6, 'Cho Gue-sung', 9, 'FW'), (6, 'Oh Hyeon-gyu', 15, 'FW'),

-- 7. Úc (AUS)
(7, 'Mathew Ryan', 1, 'GK'), (7, 'Joe Gauci', 12, 'GK'), (7, 'Harry Souttar', 19, 'DF'), (7, 'Kye Rowles', 4, 'DF'), (7, 'Aziz Behich', 16, 'DF'), (7, 'Lewis Miller', 3, 'DF'), (7, 'Jackson Irvine', 22, 'MF'), (7, 'Ajdin Hrustic', 10, 'MF'), (7, 'Keanu Baccus', 17, 'MF'), (7, 'Riley McGree', 14, 'MF'), (7, 'Craig Goodwin', 23, 'FW'), (7, 'Martin Boyle', 6, 'FW'), (7, 'Mitchell Duke', 15, 'FW'), (7, 'Kusini Yengi', 9, 'FW'),

-- 8. Ả Rập Xê Út (KSA)
(8, 'Mohammed Al-Owais', 21, 'GK'), (8, 'Nawaf Al-Aqidi', 1, 'GK'), (8, 'Ali Al-Bulaihi', 5, 'DF'), (8, 'Hassan Tambakti', 4, 'DF'), (8, 'Sultan Al-Ghannam', 2, 'DF'), (8, 'Saud Abdulhamid', 12, 'DF'), (8, 'Salem Al-Dawsari', 10, 'MF'), (8, 'Mohamed Kanno', 23, 'MF'), (8, 'Abdulelah Al-Malki', 8, 'MF'), (8, 'Abdulrahman Ghareeb', 18, 'MF'), (8, 'Firas Al-Buraikan', 9, 'FW'), (8, 'Saleh Al-Shehri', 11, 'FW'), (8, 'Abdullah Radif', 20, 'FW'),

-- 9. Pháp (FRA)
(9, 'Mike Maignan', 16, 'GK'), (9, 'Brice Samba', 1, 'GK'), (9, 'William Saliba', 4, 'DF'), (9, 'Ibrahima Konaté', 24, 'DF'), (9, 'Jules Koundé', 5, 'DF'), (9, 'Theo Hernández', 22, 'DF'), (9, 'Dayot Upamecano', 15, 'DF'), (9, 'Aurelien Tchouameni', 8, 'MF'), (9, 'Eduardo Camavinga', 6, 'MF'), (9, 'N''Golo Kanté', 13, 'MF'), (9, 'Adriens Rabiot', 14, 'MF'), (9, 'Warren Zaïre-Emery', 18, 'MF'), (9, 'Kylian Mbappé', 10, 'FW'), (9, 'Antoine Griezmann', 7, 'FW'), (9, 'Ousmane Dembélé', 11, 'FW'), (9, 'Marcus Thuram', 15, 'FW'), (9, 'Bradley Barcola', 25, 'FW'),

-- 10. Đức (GER)
(10, 'Marc-André ter Stegen', 1, 'GK'), (10, 'Oliver Baumann', 12, 'GK'), (10, 'Antonio Rüdiger', 2, 'DF'), (10, 'Jonathan Tah', 4, 'DF'), (10, 'Joshua Kimmich', 6, 'DF'), (10, 'Maximilian Mittelstädt', 18, 'DF'), (10, 'Nico Schlotterbeck', 15, 'DF'), (10, 'Jamal Musiala', 10, 'MF'), (10, 'Florian Wirtz', 17, 'MF'), (10, 'Ilkay Gündogan', 21, 'MF'), (10, 'Toni Kroos', 8, 'MF'), (10, 'Robert Andrich', 23, 'MF'), (10, 'Pascal Groß', 5, 'MF'), (10, 'Kai Havertz', 7, 'FW'), (10, 'Niclas Füllkrug', 9, 'FW'), (10, 'Leroy Sané', 19, 'FW'), (10, 'Thomas Müller', 13, 'FW'),

-- 11. Ý (ITA)
(11, 'Gianluigi Donnarumma', 1, 'GK'), (11, 'Guglielmo Vicario', 12, 'GK'), (11, 'Alessandro Bastoni', 23, 'DF'), (11, 'Riccardo Calafiori', 5, 'DF'), (11, 'Giovanni Di Lorenzo', 2, 'DF'), (11, 'Federico Dimarco', 3, 'DF'), (11, 'Gianluca Mancini', 14, 'DF'), (11, 'Nicolò Barella', 18, 'MF'), (11, 'Jorginho', 8, 'MF'), (11, 'Lorenzo Pellegrini', 10, 'MF'), (11, 'Davide Frattesi', 7, 'MF'), (11, 'Bryan Cristante', 16, 'MF'), (11, 'Federico Chiesa', 14, 'FW'), (11, 'Gianluca Scamacca', 9, 'FW'), (11, 'Mateo Retegui', 19, 'FW'), (11, 'Giacomo Raspadori', 11, 'FW'),

-- 12. Hà Lan (NED)
(12, 'Bart Verbruggen', 1, 'GK'), (12, 'Justin Bijlow', 13, 'GK'), (12, 'Virgil van Dijk', 4, 'DF'), (12, 'Nathan Aké', 5, 'DF'), (12, 'Denzel Dumfries', 22, 'DF'), (12, 'Jeremie Frimpong', 12, 'DF'), (12, 'Stefan de Vrij', 6, 'DF'), (12, 'Micky van de Ven', 15, 'DF'), (12, 'Tijjani Reijnders', 14, 'MF'), (12, 'Xavi Simons', 7, 'MF'), (12, 'Joey Veerman', 16, 'MF'), (12, 'Jerdy Schouten', 24, 'MF'), (12, 'Cody Gakpo', 11, 'FW'), (12, 'Memphis Depay', 10, 'FW'), (12, 'Wout Weghorst', 9, 'FW'), (12, 'Donyell Malen', 18, 'FW'),

-- 13. Anh (ENG)
(13, 'Jordan Pickford', 1, 'GK'), (13, 'Aaron Ramsdale', 13, 'GK'), (13, 'John Stones', 5, 'DF'), (13, 'Marc Guéhi', 6, 'DF'), (13, 'Kyle Walker', 2, 'DF'), (13, 'Luke Shaw', 3, 'DF'), (13, 'Kieran Trippier', 12, 'DF'), (13, 'Trent Alexander-Arnold', 8, 'DF'), (13, 'Jude Bellingham', 10, 'MF'), (13, 'Declan Rice', 4, 'MF'), (13, 'Kobbie Mainoo', 26, 'MF'), (13, 'Conor Gallagher', 16, 'MF'), (13, 'Harry Kane', 9, 'FW'), (13, 'Bukayo Saka', 7, 'FW'), (13, 'Phil Foden', 11, 'FW'), (13, 'Cole Palmer', 24, 'FW'), (13, 'Ollie Watkins', 19, 'FW'), (13, 'Anthony Gordon', 18, 'FW'),

-- 14. Bỉ (BEL)
(14, 'Koen Casteels', 1, 'GK'), (14, 'Matz Sels', 12, 'GK'), (14, 'Wout Faes', 4, 'DF'), (14, 'Arthur Theate', 3, 'DF'), (14, 'Timothy Castagne', 21, 'DF'), (14, 'Thomas Meunier', 15, 'DF'), (14, 'Kevin De Bruyne', 7, 'MF'), (14, 'Amadou Onana', 6, 'MF'), (14, 'Youri Tielemans', 8, 'MF'), (14, 'Orel Mangala', 18, 'MF'), (14, 'Romelu Lukaku', 10, 'FW'), (14, 'Jeremy Doku', 11, 'FW'), (14, 'Leandro Trossard', 9, 'FW'), (14, 'Lois Openda', 20, 'FW'), (14, 'Dodi Lukebakio', 14, 'FW'),

-- 15. Kroatia (CRO)
(15, 'Dominik Livaković', 1, 'GK'), (15, 'Nediljko Labrović', 12, 'GK'), (15, 'Josip Gvardiol', 4, 'DF'), (15, 'Josip Šutalo', 6, 'DF'), (15, 'Josip Juranović', 22, 'DF'), (15, 'Borna Sosa', 3, 'DF'), (15, 'Domagoj Vida', 21, 'DF'), (15, 'Luka Modrić', 10, 'MF'), (15, 'Mateo Kovačić', 8, 'MF'), (15, 'Marcelo Brozović', 11, 'MF'), (15, 'Lovro Majer', 7, 'MF'), (15, 'Luka Sučić', 25, 'MF'), (15, 'Andrej Kramarić', 9, 'FW'), (15, 'Bruno Petković', 17, 'FW'), (15, 'Ante Budimir', 16, 'FW'), (15, 'Ivan Perišić', 14, 'FW'),

-- 16. Thụy Sĩ (SUI)
(16, 'Yann Sommer', 1, 'GK'), (16, 'Gregor Kobel', 12, 'GK'), (16, 'Manuel Akanji', 5, 'DF'), (16, 'Fabian Schär', 22, 'DF'), (16, 'Ricardo Rodríguez', 13, 'DF'), (16, 'Silvan Widmer', 3, 'DF'), (16, 'Granit Xhaka', 10, 'MF'), (16, 'Remo Freuler', 8, 'MF'), (16, 'Denis Zakaria', 6, 'MF'), (16, 'Michel Aebischer', 20, 'MF'), (16, 'Xherdan Shaqiri', 23, 'FW'), (16, 'Breel Embolo', 7, 'FW'), (16, 'Dan Ndoye', 19, 'FW'), (16, 'Ruben Vargas', 17, 'FW'), (16, 'Zeki Amdouni', 25, 'FW'),

-- 17. Brasil (BRA)
(17, 'Alisson Becker', 1, 'GK'), (17, 'Ederson', 12, 'GK'), (17, 'Marquinhos', 4, 'DF'), (17, 'Gabriel Magalhães', 14, 'DF'), (17, 'Danilo', 2, 'DF'), (17, 'Lucas Beraldo', 17, 'DF'), (17, 'Eder Militão', 3, 'DF'), (17, 'Bruno Guimarães', 5, 'MF'), (17, 'Lucas Paquetá', 8, 'MF'), (17, 'Douglas Luiz', 18, 'MF'), (17, 'João Gomes', 15, 'MF'), (17, 'Andreas Pereira', 19, 'MF'), (17, 'Vinícius Júnior', 7, 'FW'), (17, 'Rodrygo Goes', 10, 'FW'), (17, 'Endrick', 9, 'FW'), (17, 'Raphinha', 11, 'FW'), (17, 'Gabriel Martinelli', 22, 'FW'), (17, 'Savinho', 20, 'FW'),

-- 18. Argentina (ARG)
(18, 'Emiliano Martínez', 23, 'GK'), (18, 'Franco Armani', 1, 'GK'), (18, 'Cristian Romero', 13, 'DF'), (18, 'Nicolas Otamendi', 19, 'DF'), (18, 'Nahuel Molina', 26, 'DF'), (18, 'Nicolas Tagliafico', 3, 'DF'), (18, 'Lisandro Martínez', 25, 'DF'), (18, 'Rodrigo De Paul', 7, 'MF'), (18, 'Alexis Mac Allister', 20, 'MF'), (18, 'Enzo Fernández', 24, 'MF'), (18, 'Leandro Paredes', 5, 'MF'), (18, 'Giovani Lo Celso', 16, 'MF'), (18, 'Lionel Messi', 10, 'FW'), (18, 'Julián Álvarez', 9, 'FW'), (18, 'Lautaro Martínez', 22, 'FW'), (18, 'Angel Di María', 11, 'FW'), (18, 'Nicolas González', 15, 'FW'),

-- 19. Uruguay (URU)
(19, 'Sergio Rochet', 1, 'GK'), (19, 'Santiago Mele', 12, 'GK'), (19, 'José María Giménez', 2, 'DF'), (19, 'Ronald Araújo', 4, 'DF'), (19, 'Mathías Olivera', 16, 'DF'), (19, 'Matias Viña', 17, 'DF'), (19, 'Guillermo Varela', 13, 'DF'), (19, 'Federico Valverde', 15, 'MF'), (19, 'Manuel Ugarte', 5, 'MF'), (19, 'Nicolas de la Cruz', 7, 'MF'), (19, 'Giorgian de Arrascaeta', 10, 'MF'), (19, 'Rodrigo Bentancur', 6, 'MF'), (19, 'Darwin Núñez', 19, 'FW'), (19, 'Luis Suárez', 9, 'FW'), (19, 'Facundo Pellistri', 11, 'FW'), (19, 'Maximiliano Araújo', 20, 'FW'),

-- 20. Colombia (COL)
(20, 'Camilo Vargas', 12, 'GK'), (20, 'David Ospina', 1, 'GK'), (20, 'Davinson Sánchez', 23, 'DF'), (20, 'Yerry Mina', 13, 'DF'), (20, 'Daniel Muñoz', 21, 'DF'), (20, 'Johan Mojica', 17, 'DF'), (20, 'Jhon Lucumí', 3, 'DF'), (20, 'James Rodríguez', 10, 'MF'), (20, 'Jefferson Lerma', 16, 'MF'), (20, 'Richard Ríos', 6, 'MF'), (20, 'Jhon Arias', 11, 'MF'), (20, 'Juan Fernando Quintero', 20, 'MF'), (20, 'Luis Díaz', 7, 'FW'), (20, 'Jhon Córdoba', 24, 'FW'), (20, 'Rafael Santos Borré', 19, 'FW'), (20, 'Jhon Durán', 14, 'FW'),

-- 21. Mỹ (USA)
(21, 'Matt Turner', 1, 'GK'), (21, 'Ethan Horvath', 12, 'GK'), (21, 'Chris Richards', 3, 'DF'), (21, 'Tim Ream', 13, 'DF'), (21, 'Antonee Robinson', 5, 'DF'), (21, 'Joe Scally', 22, 'DF'), (21, 'Cameron Carter-Vickers', 4, 'DF'), (21, 'Weston McKennie', 8, 'MF'), (21, 'Tyler Adams', 4, 'MF'), (21, 'Yunus Musah', 6, 'MF'), (21, 'Gio Reyna', 7, 'MF'), (21, 'Luca de la Torre', 14, 'MF'), (21, 'Christian Pulisic', 10, 'FW'), (21, 'Folarin Balogun', 21, 'FW'), (21, 'Timothy Weah', 21, 'FW'), (21, 'Josh Sargent', 9, 'FW'), (21, 'Haji Wright', 19, 'FW'),

-- 22. Mexico (MEX)
(22, 'Luis Malagón', 1, 'GK'), (22, 'Guillermo Ochoa', 13, 'GK'), (22, 'César Montes', 3, 'DF'), (22, 'Johan Vásquez', 5, 'DF'), (22, 'Jorge Sánchez', 2, 'DF'), (22, 'Gerardo Arteaga', 6, 'DF'), (22, 'Edson Álvarez', 4, 'MF'), (22, 'Luis Chávez', 18, 'MF'), (22, 'Erick Sánchez', 14, 'MF'), (22, 'Orbelín Pineda', 17, 'MF'), (22, 'Santiago Giménez', 11, 'FW'), (22, 'Uriel Antuna', 15, 'FW'), (22, 'Julian Quiñones', 9, 'FW'), (22, 'Alexis Vega', 10, 'FW'),

-- 23. Canada (CAN)
(23, 'Maxime Crépeau', 16, 'GK'), (23, 'Dayne St. Clair', 1, 'GK'), (23, 'Alphonso Davies', 19, 'DF'), (23, 'Moïse Bombito', 15, 'DF'), (23, 'Derek Cornelius', 13, 'DF'), (23, 'Alistair Johnston', 2, 'DF'), (23, 'Richie Laryea', 22, 'DF'), (23, 'Stephen Eustáquio', 7, 'MF'), (23, 'Ismaël Koné', 8, 'MF'), (23, 'Jonathan Osorio', 21, 'MF'), (23, 'Mathieu Choinière', 6, 'MF'), (23, 'Jonathan David', 10, 'FW'), (23, 'Cyle Larin', 9, 'FW'), (23, 'Tajon Buchanan', 11, 'FW'), (23, 'Liam Millar', 23, 'FW'),

-- 24. Costa Rica (CRC)
(24, 'Patrick Sequeira', 1, 'GK'), (24, 'Kevin Chamorro', 18, 'GK'), (24, 'Francisco Calvo', 15, 'DF'), (24, 'Juan Pablo Vargas', 3, 'DF'), (24, 'Jeyland Mitchell', 4, 'DF'), (24, 'Haxzel Quirós', 22, 'DF'), (24, 'Orlando Galo', 14, 'MF'), (24, 'Jefferson Brenes', 13, 'MF'), (24, 'Brandon Aguilera', 10, 'MF'), (24, 'Josimar Alcócer', 11, 'MF'), (24, 'Joel Campbell', 12, 'FW'), (24, 'Manfred Ugalde', 9, 'FW'), (24, 'Warren Madrigal', 17, 'FW'), (24, 'Anthony Contreras', 7, 'FW'),

-- 25. Senegal (SEN)
(25, 'Édouard Mendy', 16, 'GK'), (25, 'Mory Diaw', 1, 'GK'), (25, 'Kalidou Koulibaly', 3, 'DF'), (25, 'Abdou Diallo', 22, 'DF'), (25, 'Moussa Niakhaté', 19, 'DF'), (25, 'Ismail Jakobs', 14, 'DF'), (25, 'Idrissa Gueye', 5, 'MF'), (25, 'Pape Matar Sarr', 17, 'MF'), (25, 'Lamine Camara', 25, 'MF'), (25, 'Nampalys Mendy', 6, 'MF'), (25, 'Sadio Mané', 10, 'FW'), (25, 'Ismaïla Sarr', 18, 'FW'), (25, 'Nicolas Jackson', 11, 'FW'), (25, 'Boulaye Dia', 9, 'FW'), (25, 'Iliman Ndiaye', 13, 'FW'),

-- 26. Nigeria (NGA)
(26, 'Stanley Nwabali', 23, 'GK'), (26, 'Francis Uzoho', 1, 'GK'), (26, 'William Troost-Ekong', 5, 'DF'), (26, 'Calvin Bassey', 21, 'DF'), (26, 'Ola Aina', 2, 'DF'), (26, 'Bright Osayi-Samuel', 12, 'DF'), (26, 'Semiyi Ajayi', 6, 'DF'), (26, 'Alex Iwobi', 17, 'MF'), (26, 'Wilfred Ndidi', 4, 'MF'), (26, 'Frank Onyeka', 8, 'MF'), (26, 'Joe Aribo', 10, 'MF'), (26, 'Victor Osimhen', 9, 'FW'), (26, 'Ademola Lookman', 7, 'FW'), (26, 'Samuel Chukwueze', 11, 'FW'), (26, 'Victor Boniface', 22, 'FW'), (26, 'Kelechi Iheanacho', 14, 'FW'),

-- 27. Ai Cập (EGY)
(27, 'Mohamed El Shenawy', 1, 'GK'), (27, 'Gabaski', 16, 'GK'), (27, 'Ahmed Hegazi', 6, 'DF'), (27, 'Mohamed Abdelmonem', 24, 'DF'), (27, 'Omar Kamal', 3, 'DF'), (27, 'Mohamed Hamdy', 13, 'DF'), (27, 'Mohamed Elneny', 17, 'MF'), (27, 'Hamdy Fathi', 5, 'MF'), (27, 'Emam Ashour', 8, 'MF'), (27, 'Zizo', 21, 'MF'), (27, 'Mohamed Salah', 10, 'FW'), (27, 'Mostafa Mohamed', 11, 'FW'), (27, 'Omar Marmoush', 22, 'FW'), (27, 'Trezeguet', 7, 'FW'),

-- 28. Ghana (GHA)
(28, 'Lawrence Ati-Zigi', 1, 'GK'), (28, 'Richard Ofori', 16, 'GK'), (28, 'Mohammed Salisu', 6, 'DF'), (28, 'Alexander Djiku', 23, 'DF'), (28, 'Tariq Lamptey', 2, 'DF'), (28, 'Gideon Mensah', 14, 'DF'), (28, 'Thomas Partey', 5, 'MF'), (28, 'Mohammed Kudus', 10, 'MF'), (28, 'Salis Abdul Samed', 21, 'MF'), (28, 'Elisha Owusu', 15, 'MF'), (28, 'Iñaki Williams', 9, 'FW'), (28, 'Jordan Ayew', 11, 'FW'), (28, 'Antoine Semenyo', 25, 'FW'), (28, 'Kamaldeen Sulemana', 22, 'FW'),

-- 29. Đan Mạch (DEN)
(29, 'Kasper Schmeichel', 1, 'GK'), (29, 'Frederik Rønnow', 22, 'GK'), (29, 'Andreas Christensen', 6, 'DF'), (29, 'Joachim Andersen', 2, 'DF'), (29, 'Jannik Vestergaard', 3, 'DF'), (29, 'Joakim Mæhle', 5, 'DF'), (29, 'Victor Kristiansen', 17, 'DF'), (29, 'Christian Eriksen', 10, 'MF'), (29, 'Pierre-Emile Højbjerg', 23, 'MF'), (29, 'Morten Hjulmand', 21, 'MF'), (29, 'Thomas Delaney', 8, 'MF'), (29, 'Matt O''Riley', 15, 'MF'), (29, 'Rasmus Højlund', 9, 'FW'), (29, 'Jonas Wind', 19, 'FW'), (29, 'Yussuf Poulsen', 20, 'FW'), (29, 'Mikkel Damsgaard', 14, 'FW'),

-- 30. Áo (AUT)
(30, 'Patrick Pentz', 13, 'GK'), (30, 'Heinz Lindner', 1, 'GK'), (30, 'David Alaba', 8, 'DF'), (30, 'Stefan Posch', 5, 'DF'), (30, 'Philipp Lienhart', 15, 'DF'), (30, 'Gernot Trauner', 3, 'DF'), (30, 'Phillipp Mwene', 16, 'DF'), (30, 'Marcel Sabitzer', 9, 'MF'), (30, 'Konrad Laimer', 20, 'MF'), (30, 'Christoph Baumgartner', 19, 'MF'), (30, 'Florian Grillitsch', 10, 'MF'), (30, 'Nicolas Seiwald', 6, 'MF'), (30, 'Marko Arnautović', 7, 'FW'), (30, 'Michael Gregoritsch', 11, 'FW'), (30, 'Patrick Wimmer', 23, 'FW'),

-- 31. Ba Lan (POL)
(31, 'Wojciech Szczęsny', 1, 'GK'), (31, 'Łukasz Skorupski', 12, 'GK'), (31, 'Jan Bednarek', 5, 'DF'), (31, 'Jakub Kiwior', 14, 'DF'), (31, 'Paweł Dawidowicz', 3, 'DF'), (31, 'Przemysław Frankowski', 19, 'DF'), (31, 'Nicola Zalewski', 21, 'DF'), (31, 'Piotr Zieliński', 10, 'MF'), (31, 'Jakub Moder', 8, 'MF'), (31, 'Damian Szymański', 6, 'MF'), (31, 'Kacper Urbański', 20, 'MF'), (31, 'Robert Lewandowski', 9, 'FW'), (31, 'Karol Świderski', 16, 'FW'), (31, 'Krzysztof Piątek', 23, 'FW'), (31, 'Adam Buksa', 11, 'FW'),

-- 32. Thụy Điển (SWE)
(32, 'Robin Olsen', 1, 'GK'), (32, 'Viktor Johansson', 12, 'GK'), (32, 'Victor Lindelöf', 3, 'DF'), (32, 'Isak Hien', 4, 'DF'), (32, 'Ludwig Augustinsson', 6, 'DF'), (32, 'Emil Holm', 2, 'DF'), (32, 'Dejan Kulusevski', 21, 'MF'), (32, 'Emil Forsberg', 10, 'MF'), (32, 'Jens Cajuste', 18, 'MF'), (32, 'Mattias Svanberg', 8, 'MF'), (32, 'Hugo Larsson', 19, 'MF'), (32, 'Alexander Isak', 11, 'FW'), (32, 'Viktor Gyökeres', 9, 'FW'), (32, 'Anthony Elanga', 17, 'FW'),

-- 33. Ecuador (ECU)
(33, 'Alexander Domínguez', 22, 'GK'), (33, 'Hernán Galíndez', 1, 'GK'), (33, 'Piero Hincapié', 3, 'DF'), (33, 'Félix Torres', 2, 'DF'), (33, 'Willian Pacho', 6, 'DF'), (33, 'Angelo Preciado', 17, 'DF'), (33, 'Pervis Estupiñán', 7, 'DF'), (33, 'Moisés Caicedo', 23, 'MF'), (33, 'Carlos Gruezo', 8, 'MF'), (33, 'Alan Franco', 21, 'MF'), (33, 'Kendry Páez', 16, 'MF'), (33, 'Jeremy Sarmiento', 10, 'MF'), (33, 'Enner Valencia', 13, 'FW'), (33, 'Kevin Rodríguez', 11, 'FW'), (33, 'Jordy Caicedo', 9, 'FW'),

-- 34. Chile (CHI)
(34, 'Claudio Bravo', 1, 'GK'), (34, 'Gabriel Arias', 12, 'GK'), (34, 'Guillermo Maripán', 3, 'DF'), (34, 'Paulo Díaz', 5, 'DF'), (34, 'Gabriel Suazo', 4, 'DF'), (34, 'Mauricio Isla', 4, 'DF'), (34, 'Erick Pulgar', 13, 'MF'), (34, 'Marcelino Núñez', 7, 'MF'), (34, 'Diego Valdés', 10, 'MF'), (34, 'Rodrigo Echeverría', 18, 'MF'), (34, 'Alexis Sánchez', 7, 'FW'), (34, 'Eduardo Vargas', 11, 'FW'), (34, 'Ben Brereton Díaz', 22, 'FW'), (34, 'Víctor Dávila', 9, 'FW'),

-- 35. Peru (PER)
(35, 'Pedro Gallese', 1, 'GK'), (35, 'Carlos Cáceda', 12, 'GK'), (35, 'Carlos Zambrano', 5, 'DF'), (35, 'Alexander Callens', 22, 'DF'), (35, 'Luis Advíncula', 17, 'DF'), (35, 'Miguel Trauco', 6, 'DF'), (35, 'Oliver Sonne', 2, 'DF'), (35, 'Renato Tapia', 13, 'MF'), (35, 'Yoshimar Yotún', 19, 'MF'), (35, 'Sergio Peña', 8, 'MF'), (35, 'Piero Quispe', 10, 'MF'), (35, 'Gianluca Lapadula', 9, 'FW'), (35, 'Paolo Guerrero', 14, 'FW'), (35, 'Edison Flores', 20, 'FW'), (35, 'Bryan Reyna', 11, 'FW'),

-- 36. Paraguay (PAR)
(36, 'Carlos Coronel', 1, 'GK'), (36, 'Gatito Fernández', 12, 'GK'), (36, 'Gustavo Gómez', 15, 'DF'), (36, 'Junior Alonso', 6, 'DF'), (36, 'Omar Alderete', 3, 'DF'), (36, 'Fabrizio Peralta', 2, 'DF'), (36, 'Miguel Almirón', 10, 'MF'), (36, 'Mathías Villasanti', 23, 'MF'), (36, 'Damián Bobadilla', 8, 'MF'), (36, 'Diego Gómez', 16, 'MF'), (36, 'Ramón Sosa', 11, 'MF'), (36, 'Antonio Sanabria', 9, 'FW'), (36, 'Julio Enciso', 19, 'FW'), (36, 'Adam Bareiro', 18, 'FW'),

-- 37. Iran (IRN)
(37, 'Alireza Beiranvand', 1, 'GK'), (37, 'Hossein Hosseini', 12, 'GK'), (37, 'Shojae Khalilzadeh', 4, 'DF'), (37, 'Hossein Kanaanizadegan', 13, 'DF'), (37, 'Ramin Rezaeian', 23, 'DF'), (37, 'Milad Mohammadi', 5, 'DF'), (37, 'Saeid Ezatolahi', 6, 'MF'), (37, 'Saman Ghoddos', 14, 'MF'), (37, 'Alireza Jahanbakhsh', 7, 'MF'), (37, 'Mehdi Torabi', 11, 'MF'), (37, 'Mohammad Mohebi', 8, 'MF'), (37, 'Mehdi Taremi', 9, 'FW'), (37, 'Sardar Azmoun', 20, 'FW'), (37, 'Shahriyar Moghanlou', 18, 'FW'),

-- 38. I-rắc (IRQ)
(38, 'Jalal Hassan', 1, 'GK'), (38, 'Fahad Talib', 12, 'GK'), (38, 'Rebin Sulaka', 2, 'DF'), (38, 'Ali Adnan', 6, 'DF'), (38, 'Hussein Ali', 3, 'DF'), (38, 'Merchas Doski', 5, 'DF'), (38, 'Zidane Iqbal', 14, 'MF'), (38, 'Amir Al-Ammari', 8, 'MF'), (38, 'Ibrahim Bayesh', 17, 'MF'), (38, 'Youssef Amyn', 11, 'MF'), (38, 'Aymen Hussein', 18, 'FW'), (38, 'Ali Al-Hamadi', 9, 'FW'), (38, 'Mohanad Ali', 10, 'FW'),

-- 39. Uzbekistan (UZB)
(39, 'Utkir Yusupov', 1, 'GK'), (39, 'Abduvokhid Nematov', 12, 'GK'), (39, 'Abdukodir Khusanov', 15, 'DF'), (39, 'Husniddin Aliqulov', 2, 'DF'), (39, 'Rustam Ashurmatov', 3, 'DF'), (39, 'Farrukh Sayfiev', 4, 'DF'), (39, 'Otabek Shukurov', 7, 'MF'), (39, 'Odiljon Hamrobekov', 9, 'MF'), (39, 'Abbosbek Fayzullaev', 22, 'MF'), (39, 'Jaloliddin Masharipov', 10, 'MF'), (39, 'Eldor Shomurodov', 14, 'FW'), (39, 'Igor Sergeev', 11, 'FW'), (39, 'Oston Urunov', 11, 'FW'),

-- 40. Qatar (QAT)
(40, 'Meshaal Barsham', 22, 'GK'), (40, 'Saad Al-Sheeb', 1, 'GK'), (40, 'Boualem Khoukhi', 16, 'DF'), (40, 'Pedro Miguel', 2, 'DF'), (40, 'Lucas Mendes', 3, 'DF'), (40, 'Homam Ahmed', 14, 'DF'), (40, 'Hassan Al-Haydos', 10, 'MF'), (40, 'Akram Afif', 11, 'MF'), (40, 'Abdulaziz Hatem', 6, 'MF'), (40, 'Jassem Gaber', 23, 'MF'), (40, 'Almoez Ali', 19, 'FW'), (40, 'Mohammed Muntari', 9, 'FW'), (40, 'Youssef Msakni', 7, 'FW'),

-- 41. Cameroon (CMR)
(41, 'André Onana', 24, 'GK'), (41, 'Devis Epassy', 1, 'GK'), (41, 'Christopher Wooh,', 4, 'DF'), (41, 'Harold Moukoudi', 2, 'DF'), (41, 'Nouhou Tolo', 5, 'DF'), (41, 'Jackson Tchatchoua', 19, 'DF'), (41, 'André-Frank Zambo Anguissa', 8, 'MF'), (41, 'Olivier Ntcham', 10, 'MF'), (41, 'Pierre Kunde', 15, 'MF'), (41, 'Carlos Baleba', 17, 'MF'), (41, 'Vincent Aboubakar', 10, 'FW'), (41, 'Bryan Mbeumo', 20, 'FW'), (41, 'Karl Toko Ekambi', 11, 'FW'), (41, 'Faris Moumbagna', 9, 'FW'),

-- 42. Mali (MLI)
(42, 'Djigui Diarra', 16, 'GK'), (42, 'Ismael Diawara', 1, 'GK'), (42, 'Hamari Traoré', 2, 'DF'), (42, 'Kiki Kouyaté', 5, 'DF'), (42, 'Falaye Sacko', 17, 'DF'), (42, 'Sikou Niakaté', 3, 'DF'), (42, 'Yves Bissouma', 8, 'MF'), (42, 'Amadou Haidara', 4, 'MF'), (42, 'Mohamed Camara', 6, 'MF'), (42, 'Lassana Coulibaly', 11, 'MF'), (42, 'Kamory Doumbia', 10, 'MF'), (42, 'El Bilal Touré', 9, 'FW'), (42, 'Moussa Doumbia', 7, 'FW'), (42, 'Ibrahima Koné', 18, 'FW'),

-- 43. Bờ Biển Ngà (CIV)
(43, 'Yahia Fofana', 1, 'GK'), (43, 'Badra Ali Sangaré', 16, 'GK'), (43, 'Evan Ndicka', 21, 'DF'), (43, 'Odilon Kossounou', 7, 'DF'), (43, 'Willy Boly', 5, 'DF'), (43, 'Serge Aurier', 17, 'DF'), (43, 'Wilfried Singo', 3, 'DF'), (43, 'Franck Kessié', 8, 'MF'), (43, 'Seko Fofana', 6, 'MF'), (43, 'Ibrahim Sangaré', 18, 'MF'), (43, 'Jean Michaël Seri', 4, 'MF'), (43, 'Sébastien Haller', 22, 'FW'), (43, 'Simon Adingra', 24, 'FW'), (43, 'Nicolas Pépé', 19, 'FW'), (43, 'Oumar Diakité', 14, 'FW'), (43, 'Jeremie Boga', 10, 'FW'),

-- 44. Tunisia (TUN)
(44, 'Bechir Ben Saïd', 1, 'GK'), (44, 'Aymen Dahmen', 16, 'GK'), (44, 'Montassar Talbi', 3, 'DF'), (44, 'Yassine Meriah', 4, 'DF'), (44, 'Ali Maâloul', 12, 'DF'), (44, 'Yan Valery', 20, 'DF'), (44, 'Ellyes Skhiri', 17, 'MF'), (44, 'Aïssa Laïdouni', 14, 'MF'), (44, 'Mohamed Ali Ben Romdhane', 5, 'MF'), (44, 'Hannibal Mejbri', 10, 'MF'), (44, 'Youssef Msakni', 7, 'FW'), (44, 'Seifeddine Jaziri', 11, 'FW'), (44, 'Elias Achouri', 18, 'FW'), (44, 'Anis Ben Slimane', 25, 'FW'),

-- 45. Algeria (ALG)
(45, 'Anthony Mandrea', 23, 'GK'), (45, 'Raïs M''Bolhi', 1, 'GK'), (45, 'Ramy Bensebaini', 2, 'DF'), (45, 'Aïssa Mandi', 4, 'DF'), (45, 'Rayan Aït-Nouri', 15, 'DF'), (45, 'Youssef Atal', 20, 'DF'), (45, 'Ismaël Bennacer', 22, 'MF'), (45, 'Houssem Aouar', 8, 'MF'), (45, 'Ramiz Zerrouki', 6, 'MF'), (45, 'Nabil Bentaleb', 14, 'MF'), (45, 'Riyad Mahrez', 7, 'FW'), (45, 'Baghdad Bounedjah', 9, 'FW'), (45, 'Amine Gouiri', 11, 'FW'), (45, 'Said Benrahma', 10, 'FW'), (45, 'Youcef Belaïli', 8, 'FW'),

-- 46. Thổ Nhĩ Kỳ (TUR)
(46, 'Mert Günok', 1, 'GK'), (46, 'Uğurcan Çakır', 23, 'GK'), (46, 'Merih Demiral', 3, 'DF'), (46, 'Samet Akaydin', 14, 'DF'), (46, 'Zeki Çelik', 2, 'DF'), (46, 'Ferdi Kadıoğlu', 18, 'DF'), (46, 'Abdulkerim Bardakcı', 4, 'DF'), (46, 'Hakan Çalhanoğlu', 10, 'MF'), (46, 'Kaan Ayhan', 22, 'MF'), (46, 'Orkun Kökçü', 6, 'MF'), (46, 'Salih Özcan', 5, 'MF'), (46, 'Arda Güler', 8, 'MF'), (46, 'Barış Alper Yılmaz', 21, 'FW'), (46, 'Kenan Yıldız', 19, 'FW'), (46, 'Kerem Aktürkoğlu', 7, 'FW'), (46, 'Cenk Tosun', 9, 'FW'),

-- 47. Ukraina (UKR)
(47, 'Andriy Lunin', 1, 'GK'), (47, 'Anatoliy Trubin', 12, 'GK'), (47, 'Illya Zabarnyi', 13, 'DF'), (47, 'Mykola Matviyenko', 22, 'DF'), (47, 'Oleksandr Zinchenko', 17, 'DF'), (47, 'Vitaliy Mykolenko', 16, 'DF'), (47, 'Yukhym Konoplya', 2, 'DF'), (47, 'Heorhiy Sudakov', 14, 'MF'), (47, 'Taras Stepanenko', 6, 'MF'), (47, 'Mykhailo Mudryk', 10, 'MF'), (47, 'Viktor Tsyhankov', 15, 'MF'), (47, 'Ruslan Malinovskyi', 8, 'MF'), (47, 'Artem Dovbyk', 11, 'FW'), (47, 'Roman Yaremchuk', 9, 'FW'), (47, 'Vladyslav Vanat', 25, 'FW'),

-- 48. Serbia (SRB)
(48, 'Predrag Rajković', 1, 'GK'), (48, 'Vanja Milinković-Savić', 23, 'GK'), (48, 'Nikola Milenković', 4, 'DF'), (48, 'Strahinja Pavlović', 2, 'DF'), (48, 'Miloš Veljković', 13, 'DF'), (48, 'Srđan Babić', 15, 'DF'), (48, 'Dušan Tadić', 10, 'MF'), (48, 'Sergej Milinković-Savić', 20, 'MF'), (48, 'Nemanja Gudelj', 6, 'MF'), (48, 'Saša Lukić', 16, 'MF'), (48, 'Lazar Samardžić', 7, 'MF'), (48, 'Aleksandar Mitrović', 9, 'FW'), (48, 'Dušan Vlahović', 7, 'FW'), (48, 'Luka Jović', 8, 'FW'), (48, 'Filip Kostić', 17, 'FW');

-- 9. TRẬN ĐẤU MẪU
INSERT INTO matches (id, match_number, stage, stadium_id, home_team_id, away_team_id, match_time, match_date, status, match_status) VALUES
(1, 1, 'GROUP', 1, 1, 4, '2030-06-13 20:00:00', '2030-06-13 20:00:00', 'UPCOMING', 'UPCOMING'),
(2, 2, 'GROUP', 10, 2, 3, '2030-06-14 18:00:00', '2030-06-14 18:00:00', 'UPCOMING', 'UPCOMING'),
(3, 3, 'GROUP', 5, 5, 6, '2030-06-14 21:00:00', '2030-06-14 21:00:00', 'UPCOMING', 'UPCOMING'),
(4, 4, 'GROUP', 12, 7, 8, '2030-06-15 15:00:00', '2030-06-15 15:00:00', 'UPCOMING', 'UPCOMING'),
(5, 5, 'GROUP', 13, 9, 10, '2030-06-15 18:00:00', '2030-06-15 18:00:00', 'UPCOMING', 'UPCOMING'),
(6, 6, 'GROUP', 2, 11, 12, '2030-06-15 21:00:00', '2030-06-15 21:00:00', 'UPCOMING', 'UPCOMING'),
(7, 7, 'GROUP', 4, 13, 14, '2030-06-16 18:00:00', '2030-06-16 18:00:00', 'UPCOMING', 'UPCOMING'),
(8, 8, 'GROUP', 3, 15, 16, '2030-06-16 21:00:00', '2030-06-16 21:00:00', 'UPCOMING', 'UPCOMING'),
(9, 9, 'GROUP', 1, 17, 18, '2030-06-17 18:00:00', '2030-06-17 18:00:00', 'UPCOMING', 'UPCOMING'),
(10, 10, 'GROUP', 11, 19, 20, '2030-06-17 21:00:00', '2030-06-17 21:00:00', 'UPCOMING', 'UPCOMING'),
(11, 11, 'GROUP', 15, 21, 22, '2030-06-18 18:00:00', '2030-06-18 18:00:00', 'UPCOMING', 'UPCOMING'),
(12, 12, 'GROUP', 14, 25, 26, '2030-06-18 21:00:00', '2030-06-18 21:00:00', 'UPCOMING', 'UPCOMING'),
(13, 13, 'GROUP', 8, 29, 30, '2030-06-19 18:00:00', '2030-06-19 18:00:00', 'UPCOMING', 'UPCOMING'),
(14, 14, 'GROUP', 6, 33, 34, '2030-06-19 21:00:00', '2030-06-19 21:00:00', 'UPCOMING', 'UPCOMING'),
(15, 15, 'GROUP', 16, 37, 38, '2030-06-20 18:00:00', '2030-06-20 18:00:00', 'UPCOMING', 'UPCOMING'),
(16, 16, 'GROUP', 7, 41, 42, '2030-06-20 21:00:00', '2030-06-20 21:00:00', 'UPCOMING', 'UPCOMING'),
(17, 17, 'GROUP', 9, 45, 46, '2030-06-21 20:00:00', '2030-06-21 20:00:00', 'UPCOMING', 'UPCOMING'),
(18, 73, 'ROUND_32', 2, NULL, NULL, '2030-07-01 18:00:00', '2030-07-01 18:00:00', 'UPCOMING', 'UPCOMING'),
(19, 89, 'ROUND_16', 1, NULL, NULL, '2030-07-06 20:00:00', '2030-07-06 20:00:00', 'UPCOMING', 'UPCOMING'),
(20, 97, 'QUARTER_FINAL', 13, NULL, NULL, '2030-07-10 21:00:00', '2030-07-10 21:00:00', 'UPCOMING', 'UPCOMING'),
(21, 101, 'SEMI_FINAL', 2, NULL, NULL, '2030-07-14 21:00:00', '2030-07-14 21:00:00', 'UPCOMING', 'UPCOMING'),
(22, 103, 'THIRD_PLACE', 10, NULL, NULL, '2030-07-18 18:00:00', '2030-07-18 18:00:00', 'UPCOMING', 'UPCOMING'),
(23, 104, 'FINAL', 13, NULL, NULL, '2030-07-21 20:00:00', '2030-07-21 20:00:00', 'UPCOMING', 'UPCOMING');

-- 10. SINH GHẾ MẪU BAN ĐẦU CHO TRẬN 1 (KHAI MẠC)
CREATE TEMPORARY TABLE IF NOT EXISTS seq_100 (n INT PRIMARY KEY);
INSERT INTO seq_100 (n) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
(41),(42),(43),(44),(45),(46),(47),(48),(49),(50);

INSERT IGNORE INTO match_seats (match_id, seat_zone_id, seat_code, price, status)
SELECT 1, 1, CONCAT('VIP-BLK', b.n, '-R', r.n, '-', LPAD(s.seat_num, 2, '0')), 8500000.00, 'AVAILABLE'
FROM seq_100 b
JOIN seq_100 r ON r.n <= 5
JOIN (
    SELECT 1 AS seat_num UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
    UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
    UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25
) s
WHERE b.n <= 2;

INSERT IGNORE INTO match_seats (match_id, seat_zone_id, seat_code, price, status)
SELECT 1, 32, CONCAT('STD-', sec.sec_code, '-BLK', (100 + b.n), '-R', r.n, '-', LPAD(s.seat_num, 2, '0')), 2500000.00, 'AVAILABLE'
FROM (SELECT 'A' AS sec_code UNION ALL SELECT 'B' AS sec_code) sec
JOIN seq_100 b ON b.n <= 2
JOIN seq_100 r ON r.n <= 4
JOIN (
    SELECT 1 AS seat_num UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
    UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
    UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25
) s;

DROP TEMPORARY TABLE IF EXISTS seq_100;


-- ============================================================================
-- BỔ SUNG CỘT BẢNG ĐẤU & BẢNG VỊ TRÍ CHỜ (PLACEHOLDERS) CHO VÒNG KNOCK-OUT
-- ============================================================================
ALTER TABLE matches 
ADD COLUMN home_placeholder VARCHAR(50) NULL AFTER away_team_id,
ADD COLUMN away_placeholder VARCHAR(50) NULL AFTER home_placeholder,
ADD COLUMN winner_team_id INT NULL AFTER away_score,
ADD CONSTRAINT fk_matches_winner FOREIGN KEY (winner_team_id) REFERENCES teams(id) ON DELETE SET NULL;

-- ============================================================================
-- CẤU TRÚC 104 TRẬN ĐẤU CHUẨN FIFA WORLD CUP (VÒNG BẢNG & VÒNG KNOCK-OUT)
-- ============================================================================

-- A. VÒNG BẢNG (72 TRẬN ĐẤU - 12 BẢNG A TỚI L)
-- BẢNG A
INSERT INTO matches (match_number, stage, stadium_id, home_team_id, away_team_id, home_placeholder, away_placeholder, match_time) VALUES
(1,  'GROUP', 1, 1, 2, 'A1', 'A2', '2030-06-13 20:00:00'),
(2,  'GROUP', 2, 3, 4, 'A3', 'A4', '2030-06-14 15:00:00'),
(3,  'GROUP', 1, 1, 3, 'A1', 'A3', '2030-06-18 18:00:00'),
(4,  'GROUP', 2, 4, 2, 'A4', 'A2', '2030-06-18 21:00:00'),
(5,  'GROUP', 1, 4, 1, 'A4', 'A1', '2030-06-23 20:00:00'),
(6,  'GROUP', 2, 2, 3, 'A2', 'A3', '2030-06-23 20:00:00');

-- BẢNG B
INSERT INTO matches (match_number, stage, stadium_id, home_team_id, away_team_id, home_placeholder, away_placeholder, match_time) VALUES
(7,  'GROUP', 3, 5, 6, 'B1', 'B2', '2030-06-14 18:00:00'),
(8,  'GROUP', 4, 7, 8, 'B3', 'B4', '2030-06-14 21:00:00'),
(9,  'GROUP', 3, 5, 7, 'B1', 'B3', '2030-06-19 18:00:00'),
(10, 'GROUP', 4, 8, 6, 'B4', 'B2', '2030-06-19 21:00:00'),
(11, 'GROUP', 3, 8, 5, 'B4', 'B1', '2030-06-24 18:00:00'),
(12, 'GROUP', 4, 6, 7, 'B2', 'B3', '2030-06-24 18:00:00');

-- BẢNG C
INSERT INTO matches (match_number, stage, stadium_id, home_team_id, away_team_id, home_placeholder, away_placeholder, match_time) VALUES
(13, 'GROUP', 10, 9, 10,  'C1', 'C2', '2030-06-15 15:00:00'),
(14, 'GROUP', 11, 11, 12, 'C3', 'C4', '2030-06-15 18:00:00'),
(15, 'GROUP', 10, 9, 11,  'C1', 'C3', '2030-06-20 18:00:00'),
(16, 'GROUP', 11, 12, 10, 'C4', 'C2', '2030-06-20 21:00:00'),
(17, 'GROUP', 10, 12, 9,  'C4', 'C1', '2030-06-25 21:00:00'),
(18, 'GROUP', 11, 10, 11, 'C2', 'C3', '2030-06-25 21:00:00');

-- BẢNG D
INSERT INTO matches (match_number, stage, stadium_id, home_team_id, away_team_id, home_placeholder, away_placeholder, match_time) VALUES
(19, 'GROUP', 13, 13, 14, 'D1', 'D2', '2030-06-15 21:00:00'),
(20, 'GROUP', 14, 15, 16, 'D3', 'D4', '2030-06-16 15:00:00'),
(21, 'GROUP', 13, 13, 15, 'D1', 'D3', '2030-06-21 18:00:00'),
(22, 'GROUP', 14, 16, 14, 'D4', 'D2', '2030-06-21 21:00:00'),
(23, 'GROUP', 13, 16, 13, 'D4', 'D1', '2030-06-26 18:00:00'),
(24, 'GROUP', 14, 14, 15, 'D2', 'D3', '2030-06-26 18:00:00');

-- B. VÒNG KNOCK-OUT
-- 1. VÒNG 1/16 (ROUND OF 32: TRẬN 73 - 88)
INSERT INTO matches (match_number, stage, stadium_id, home_placeholder, away_placeholder, match_time) VALUES
(73, 'ROUND_32', 1,  '1A', '2B',          '2030-06-29 18:00:00'),
(74, 'ROUND_32', 2,  '1C', '2D',          '2030-06-29 21:00:00'),
(75, 'ROUND_32', 3,  '1E', '2F',          '2030-06-30 18:00:00'),
(76, 'ROUND_32', 4,  '1G', '2H',          '2030-06-30 21:00:00'),
(77, 'ROUND_32', 5,  '1I', '2J',          '2030-07-01 18:00:00'),
(78, 'ROUND_32', 6,  '1K', '2L',          '2030-07-01 21:00:00'),
(79, 'ROUND_32', 7,  '1B', '3A/C/D/F',    '2030-07-02 18:00:00'),
(80, 'ROUND_32', 8,  '1D', '3B/E/F/I',    '2030-07-02 21:00:00'),
(81, 'ROUND_32', 9,  '1F', '3C/G/H/J',    '2030-07-03 18:00:00'),
(82, 'ROUND_32', 10, '1H', '3D/I/J/K',    '2030-07-03 21:00:00'),
(83, 'ROUND_32', 11, '1J', '3E/H/K/L',    '2030-07-04 18:00:00'),
(84, 'ROUND_32', 12, '1L', '3A/B/G/I',    '2030-07-04 21:00:00'),
(85, 'ROUND_32', 13, '2A', '2C',          '2030-07-05 18:00:00'),
(86, 'ROUND_32', 14, '2E', '2G',          '2030-07-05 21:00:00'),
(87, 'ROUND_32', 15, '2I', '2K',          '2030-07-06 18:00:00'),
(88, 'ROUND_32', 16, '2H', '2J',          '2030-07-06 21:00:00');

-- 2. VÒNG 1/8 (ROUND OF 16: TRẬN 89 - 96)
INSERT INTO matches (match_number, stage, stadium_id, home_placeholder, away_placeholder, match_time) VALUES
(89, 'ROUND_16', 1, 'Thắng 73', 'Thắng 74', '2030-07-08 18:00:00'),
(90, 'ROUND_16', 2, 'Thắng 75', 'Thắng 76', '2030-07-08 21:00:00'),
(91, 'ROUND_16', 3, 'Thắng 77', 'Thắng 78', '2030-07-09 18:00:00'),
(92, 'ROUND_16', 4, 'Thắng 79', 'Thắng 80', '2030-07-09 21:00:00'),
(93, 'ROUND_16', 5, 'Thắng 81', 'Thắng 82', '2030-07-10 18:00:00'),
(94, 'ROUND_16', 6, 'Thắng 83', 'Thắng 84', '2030-07-10 21:00:00'),
(95, 'ROUND_16', 7, 'Thắng 85', 'Thắng 86', '2030-07-11 18:00:00'),
(96, 'ROUND_16', 8, 'Thắng 87', 'Thắng 88', '2030-07-11 21:00:00');

-- 3. TỨ KẾT (QUARTER FINAL: TRẬN 97 - 100)
INSERT INTO matches (match_number, stage, stadium_id, home_placeholder, away_placeholder, match_time) VALUES
(97,  'QUARTER_FINAL', 1,  'Thắng 89', 'Thắng 90', '2030-07-13 18:00:00'),
(98,  'QUARTER_FINAL', 2,  'Thắng 91', 'Thắng 92', '2030-07-13 21:00:00'),
(99,  'QUARTER_FINAL', 10, 'Thắng 93', 'Thắng 94', '2030-07-14 18:00:00'),
(100, 'QUARTER_FINAL', 13, 'Thắng 95', 'Thắng 96', '2030-07-14 21:00:00');

-- 4. BÁN KẾT (SEMI FINAL: TRẬN 101 - 102)
INSERT INTO matches (match_number, stage, stadium_id, home_placeholder, away_placeholder, match_time) VALUES
(101, 'SEMI_FINAL', 1,  'Thắng 97', 'Thắng 98',  '2030-07-17 20:00:00'),
(102, 'SEMI_FINAL', 2,  'Thắng 99', 'Thắng 100', '2030-07-18 20:00:00');

-- 5. TRANH HẠNG 3 (THIRD PLACE: TRẬN 103)
INSERT INTO matches (match_number, stage, stadium_id, home_placeholder, away_placeholder, match_time) VALUES
(103, 'THIRD_PLACE', 10, 'Thua 101', 'Thua 102', '2030-07-20 18:00:00');

-- 6. CHUNG KẾT (FINAL: TRẬN 104)
INSERT INTO matches (match_number, stage, stadium_id, home_placeholder, away_placeholder, match_time) VALUES
(104, 'FINAL', 1, 'Thắng 101', 'Thắng 102', '2030-07-21 20:00:00');


-- ============================================================================
-- 1. CẬP NHẬT SỨC CHỨA SÂN VẬN ĐỘNG & KHU VỰC GHẾ (300 VIP + 700 THƯỜNG)
-- ============================================================================

-- Cập nhật sức chứa sân vận động về 1000
ALTER TABLE stadiums MODIFY COLUMN capacity INT NOT NULL DEFAULT 1000;
UPDATE stadiums SET capacity = 1000;

-- Xóa dữ liệu phân khu cũ và nạp lại chuẩn 300 VIP + 700 STANDARD
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE seat_zones;
SET FOREIGN_KEY_CHECKS = 1;

-- Thêm 300 ghế VIP cho mỗi sân
INSERT INTO seat_zones (stadium_id, ticket_type_id, zone_name, name, type, total_seats, base_price)
SELECT id, 1, 'Khán đài VIP', 'Khán đài VIP', 'VIP', 300, 8500000.00 FROM stadiums;

-- Thêm 700 ghế Thường cho mỗi sân
INSERT INTO seat_zones (stadium_id, ticket_type_id, zone_name, name, type, total_seats, base_price)
SELECT id, 2, 'Khán đài Phổ Thông', 'Khán đài Phổ Thông', 'STANDARD', 700, 2500000.00 FROM stadiums;


-- ============================================================================
-- 2. STORED PROCEDURE: TỰ ĐỘNG SINH 1,000 GHẾ CHO TRẬN ĐẤU (300 VIP + 700 STD)
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_generate_match_seats//

CREATE PROCEDURE sp_generate_match_seats(IN p_match_id INT)
BEGIN
    DECLARE v_stadium_id INT;
    DECLARE v_vip_zone_id INT;
    DECLARE v_std_zone_id INT;
    DECLARE v_i INT DEFAULT 1;

    -- Lấy stadium_id của trận đấu
    SELECT stadium_id INTO v_stadium_id FROM matches WHERE id = p_match_id;

    -- Lấy id của khu vực ghế VIP và STANDARD
    SELECT id INTO v_vip_zone_id FROM seat_zones WHERE stadium_id = v_stadium_id AND type = 'VIP' LIMIT 1;
    SELECT id INTO v_std_zone_id FROM seat_zones WHERE stadium_id = v_stadium_id AND type = 'STANDARD' LIMIT 1;

    -- Sinh 300 ghế VIP (VIP-001 tới VIP-300)
    SET v_i = 1;
    WHILE v_i <= 300 DO
        INSERT IGNORE INTO match_seats (match_id, seat_zone_id, seat_code, price, status)
        VALUES (p_match_id, v_vip_zone_id, CONCAT('VIP-', LPAD(v_i, 3, '0')), 8500000.00, 'AVAILABLE');
        SET v_i = v_i + 1;
    END WHILE;

    -- Sinh 700 ghế STANDARD (STD-001 tới STD-700)
    SET v_i = 1;
    WHILE v_i <= 700 DO
        INSERT IGNORE INTO match_seats (match_id, seat_zone_id, seat_code, price, status)
        VALUES (p_match_id, v_std_zone_id, CONCAT('STD-', LPAD(v_i, 3, '0')), 2500000.00, 'AVAILABLE');
        SET v_i = v_i + 1;
    END WHILE;
END//

-- ============================================================================
-- 3. STORED PROCEDURE: TỰ ĐỘNG ĐẶT 1 GHẾ & SINH VÉ KHI MUA VÉ
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_buy_ticket//

CREATE PROCEDURE sp_buy_ticket(
    IN p_user_id INT,
    IN p_match_id INT,
    IN p_ticket_type ENUM('VIP', 'STANDARD'),
    OUT p_ticket_code VARCHAR(64),
    OUT p_order_id INT
)
BEGIN
    DECLARE v_seat_id INT DEFAULT NULL;
    DECLARE v_seat_price DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_order_code VARCHAR(64);
    DECLARE v_generated_ticket_code VARCHAR(64);

    -- 1. Tìm 1 ghế còn trống thuộc loại vé yêu cầu
    SELECT ms.id, ms.price INTO v_seat_id, v_seat_price
    FROM match_seats ms
    JOIN seat_zones sz ON ms.seat_zone_id = sz.id
    WHERE ms.match_id = p_match_id 
      AND sz.type = p_ticket_type 
      AND ms.status = 'AVAILABLE'
    LIMIT 1
    FOR UPDATE;

    -- Kiểm tra nếu còn ghế trống
    IF v_seat_id IS NOT NULL THEN
        -- Đổi trạng thái ghế sang BOOKED
        UPDATE match_seats SET status = 'BOOKED' WHERE id = v_seat_id;

        -- Tạo mã đơn hàng & mã vé ngẫu nhiên
        SET v_order_code = CONCAT('ORD-', UNIX_TIMESTAMP(), '-', FLOOR(RAND() * 8999 + 1000));
        SET v_generated_ticket_code = CONCAT('TKT-WC2030-', UPPER(SUBSTRING(MD5(RAND()), 1, 10)));

        -- 2. Sinh Đơn hàng (orders)
        INSERT INTO orders (user_id, order_code, total_price, total_amount, status, payment_status, payment_method)
        VALUES (p_user_id, v_order_code, v_seat_price, v_seat_price, 'PAID', 'PAID', 'SIMULATION');
        
        SET p_order_id = LAST_INSERT_ID();

        -- 3. Tự động sinh Vé (tickets)
        INSERT INTO tickets (order_id, match_id, match_seat_id, ticket_code, price, status)
        VALUES (p_order_id, p_match_id, v_seat_id, v_generated_ticket_code, v_seat_price, 'VALID');

        -- 4. Tự động sinh Thanh toán (payments)
        INSERT INTO payments (order_id, payment_method, transaction_id, amount, status)
        VALUES (p_order_id, 'SIMULATION', CONCAT('TXN-', UNIX_TIMESTAMP()), v_seat_price, 'SUCCESS');

        SET p_ticket_code = v_generated_ticket_code;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loại vé này cho trận đấu đã hết chỗ!';
    END IF;
END//

DELIMITER ;

-- ============================================================================
-- 4. TRIGGER: TỰ ĐỘNG KHỞI TẠO 1.000 GHẾ BẤT CỨ KHI NÀO TẠO TRẬN ĐẤU MỚI
-- ============================================================================
DELIMITER //
DROP TRIGGER IF EXISTS trg_after_match_insert_generate_seats//

CREATE TRIGGER trg_after_match_insert_generate_seats
AFTER INSERT ON matches
FOR EACH ROW
BEGIN
    CALL sp_generate_match_seats(NEW.id);
END//
DELIMITER ;