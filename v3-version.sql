BEGIN;

-- Изменение типа столбца fee 
ALTER TABLE book_clubs
    ALTER COLUMN fee TYPE DECIMAL(10, 2);

-- Добавление столбца phone_number
ALTER TABLE readers
    ADD COLUMN phone_number VARCHAR(15);

-- Добавление столбца description
ALTER TABLE book_clubs
    ADD COLUMN description TEXT;

-- Добавление ограничения NOT NULL на столбец email
ALTER TABLE readers
    ALTER COLUMN email SET NOT NULL;

-- Обновление таблицы attendance_history
UPDATE attendance_history a
SET meeting_id = sub.min_meeting_id
FROM (
    SELECT meeting_topic, MIN(meeting_id) AS min_meeting_id
    FROM meetings
    GROUP BY meeting_topic
) sub
JOIN meetings m ON m.meeting_topic = sub.meeting_topic
WHERE a.meeting_id = m.meeting_id
  AND m.meeting_id <> sub.min_meeting_id;

-- Удаление дубликатов из таблицы meetings.
DELETE FROM meetings
WHERE meeting_id NOT IN (
    SELECT MIN(meeting_id)
    FROM meetings
    GROUP BY meeting_topic
);

-- Добавление уникального ограничения на столбец meeting_topic 
ALTER TABLE meetings
    ADD CONSTRAINT unique_meeting_topic UNIQUE (meeting_topic);

-- Добавление ограничения CHECK на столбец phone_number 
ALTER TABLE readers
    ADD CONSTRAINT check_phone_number CHECK (phone_number ~ '^[0-9+ -]+$');

-- Добавление нового столбца meeting_duration (в минутах) в таблицу meetings с дефолтным значением 60
ALTER TABLE meetings
    ADD COLUMN meeting_duration INT DEFAULT 60 CHECK (meeting_duration > 0);

-- Добавление ограничения FOREIGN KEY в таблице attendance_history,
ALTER TABLE attendance_history
    ADD CONSTRAINT fk_meeting_id FOREIGN KEY (meeting_id)
        REFERENCES meetings(meeting_id) ON DELETE CASCADE;

COMMIT;

