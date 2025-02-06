-- Таблица читателей книжного клуба
CREATE TABLE readers
(
    reader_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    join_date   DATE,
    membership_level VARCHAR(50)  -- например Стандарт, Премиум
);

-- Таблица книжных клубов
CREATE TABLE book_clubs
(
    club_id   SERIAL PRIMARY KEY,
    club_name VARCHAR(300) NOT NULL,
    start_date DATE,
    end_date   DATE,
    fee        NUMERIC(10,2)  -- бюджет клуба
);

-- Таблица встреч клуба
CREATE TABLE meetings
(
    meeting_id   SERIAL PRIMARY KEY,
    club_id      INT,
    meeting_topic VARCHAR(255) NOT NULL,
    description  TEXT,
    start_time   TIMESTAMP,
    end_time     TIMESTAMP,
    status       VARCHAR(50) DEFAULT 'Planned',  -- статус встречи например Planned, Completed
    FOREIGN KEY (club_id) REFERENCES book_clubs(club_id)
);

-- Таблица ролей участников в клубе
CREATE TABLE club_roles
(
    role_id   SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL  -- например Организатор, Ведущий, Участник
);

-- Таблица связи участников и ролей в клубах
CREATE TABLE reader_club_roles
(
    reader_id INT,
    club_id   INT,
    role_id   INT,
    PRIMARY KEY (reader_id, club_id, role_id),
    FOREIGN KEY (reader_id) REFERENCES readers(reader_id),
    FOREIGN KEY (club_id) REFERENCES book_clubs(club_id),
    FOREIGN KEY (role_id) REFERENCES club_roles(role_id)
);

-- Таблица истории посещаемости встреч
CREATE TABLE attendance_history
(
    attendance_id SERIAL PRIMARY KEY,
    reader_id     INT,
    meeting_id    INT,
    attendance_status VARCHAR(20),  -- например Present или Absent
    attendance_date   DATE,
    FOREIGN KEY (reader_id) REFERENCES readers(reader_id),
    FOREIGN KEY (meeting_id) REFERENCES meetings(meeting_id)
);
