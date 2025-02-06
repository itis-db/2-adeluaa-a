BEGIN;

--Удаляем внешние ключи, чтобы можно было менять ключи в родительских таблицах
ALTER TABLE reader_club_roles DROP CONSTRAINT IF EXISTS reader_club_roles_reader_id_fkey;
ALTER TABLE reader_club_roles DROP CONSTRAINT IF EXISTS reader_club_roles_club_id_fkey;
ALTER TABLE reader_club_roles DROP CONSTRAINT IF EXISTS reader_club_roles_role_id_fkey;
ALTER TABLE attendance_history DROP CONSTRAINT IF EXISTS attendance_history_meeting_id_fkey;
ALTER TABLE attendance_history DROP CONSTRAINT IF EXISTS attendance_history_reader_id_fkey;
ALTER TABLE meetings DROP CONSTRAINT IF EXISTS meetings_club_id_fkey;


-- Таблица readers (Читатели)
-- Новый ключ: email (доменный ключ)
CREATE TABLE readers_new (
    email VARCHAR(100) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    join_date DATE,
    membership_level VARCHAR(50),
    phone_number VARCHAR(15)
);

INSERT INTO readers_new (email, first_name, last_name, join_date, membership_level, phone_number)
SELECT email, first_name, last_name, join_date, membership_level, phone_number
FROM readers;

DROP TABLE readers;
ALTER TABLE readers_new RENAME TO readers;

-- Таблица book_clubs (Книжные клубы)
-- Новый ключ: (club_name, start_date)
CREATE TABLE book_clubs_new (
    club_name VARCHAR(300),
    start_date DATE,
    end_date DATE,
    fee DECIMAL(10,2),
    description TEXT,
    PRIMARY KEY (club_name, start_date)
);

INSERT INTO book_clubs_new (club_name, start_date, end_date, fee, description)
SELECT club_name, start_date, end_date, fee, description
FROM book_clubs;

DROP TABLE book_clubs;
ALTER TABLE book_clubs_new RENAME TO book_clubs;


-- Таблица meetings (Встречи)
-- Новый ключ: (meeting_topic, club_name, club_start)
CREATE TABLE meetings_new (
    meeting_topic   VARCHAR(255),
    club_name       VARCHAR(300),
    club_start      DATE,
    description     TEXT,
    start_time      TIMESTAMP,
    end_time        TIMESTAMP,
    status          VARCHAR(50),
    meeting_duration INT DEFAULT 60,
    PRIMARY KEY (meeting_topic, club_name, club_start),
    FOREIGN KEY (club_name, club_start) REFERENCES book_clubs (club_name, start_date)
);

INSERT INTO meetings_new (meeting_topic, club_name, club_start, description, start_time, end_time, status, meeting_duration)
SELECT m.meeting_topic,
       b.club_name,
       b.start_date,
       m.description,
       m.start_time,
       m.end_time,
       m.status,
       m.meeting_duration
FROM meetings m
JOIN book_clubs b ON m.club_id = b.club_id;

DROP TABLE meetings;
ALTER TABLE meetings_new RENAME TO meetings;

--Таблица club_roles (Роли)
-- Новый ключ: role_name (доменный ключ)
CREATE TABLE club_roles_new (
    role_name VARCHAR(100) PRIMARY KEY
);

INSERT INTO club_roles_new (role_name)
SELECT role_name FROM club_roles;

DROP TABLE club_roles;
ALTER TABLE club_roles_new RENAME TO club_roles;

--Таблица reader_club_roles (Связь читателей и ролей в клубах)
--Новый ключ: (email, club_name, club_start, role_name)
CREATE TABLE reader_club_roles_new (
    email VARCHAR(100),
    club_name VARCHAR(300),
    club_start DATE,
    role_name VARCHAR(100),
    PRIMARY KEY (email, club_name, club_start, role_name),
    FOREIGN KEY (email) REFERENCES readers (email),
    FOREIGN KEY (club_name, club_start) REFERENCES book_clubs (club_name, start_date),
    FOREIGN KEY (role_name) REFERENCES club_roles (role_name)
);

INSERT INTO reader_club_roles_new (email, club_name, club_start, role_name)
SELECT 
    r.email,
    b.club_name,
    b.start_date,
    cr.role_name
FROM reader_club_roles cr
JOIN readers r ON cr.reader_id = r.reader_id
JOIN book_clubs b ON cr.club_id = b.club_id
JOIN club_roles c ON cr.role_id = c.role_id;

DROP TABLE reader_club_roles;
ALTER TABLE reader_club_roles_new RENAME TO reader_club_roles;


--Таблица attendance_history (История посещаемости)
-- Новый ключ: (email, meeting_topic, club_name, club_start, attendance_date)


CREATE TABLE attendance_history_new (
    email VARCHAR(100),
    meeting_topic VARCHAR(255),
    club_name VARCHAR(300),
    club_start DATE,
    attendance_date DATE,
    hours_worked VARCHAR(20),
    PRIMARY KEY (email, meeting_topic, club_name, club_start, attendance_date),
    FOREIGN KEY (email) REFERENCES readers (email),
    FOREIGN KEY (meeting_topic, club_name, club_start) REFERENCES meetings (meeting_topic, club_name, club_start)
);

INSERT INTO attendance_history_new (email, meeting_topic, club_name, club_start, attendance_date, hours_worked)
SELECT 
    r.email,
    m.meeting_topic,
    b.club_name,
    b.start_date,
    a.attendance_date,
    a.hours_worked
FROM attendance_history a
JOIN readers r ON a.reader_id = r.reader_id
JOIN meetings m ON a.meeting_id = m.meeting_id
JOIN book_clubs b ON m.club_id = b.club_id;

DROP TABLE attendance_history;
ALTER TABLE attendance_history_new RENAME TO attendance_history;

COMMIT;

