DO
$$
DECLARE
    i INT := 0;
BEGIN
    WHILE i < 200 LOOP
        INSERT INTO readers (first_name, last_name, email, join_date, membership_level)
        VALUES (
            substring(md5(random()::text) from 1 for 6),  -- случайное имя
            substring(md5(random()::text) from 1 for 8),  -- случайная фамилия
            substring(md5(random()::text) from 1 for 5) || i || '@mail.com',  -- email
            CURRENT_DATE - (floor(random() * 1825))::int,  -- дата до 5 лет назад (1825 дней)
            CASE WHEN random() < 0.7 THEN 'Standard' ELSE 'Premium' END  -- 70% Standard, 30% Premium
        );
        i := i + 1;
    END LOOP;
END
$$;


DO
$$
DECLARE
    i INT := 0;
BEGIN
    WHILE i < 50 LOOP
        INSERT INTO book_clubs (club_name, start_date, end_date, fee)
        VALUES (
            'Book Club ' || (i + 1),
            CURRENT_DATE - (floor(random() * 1095))::int,  -- до 3 лет назад (1095 дней)
            CURRENT_DATE + (floor(random() * 730))::int,     -- до 2 лет вперед (730 дней)
            (floor(random() * 100) + 10)  -- взнос от 10 до 110
        );
        i := i + 1;
    END LOOP;
END
$$;


INSERT INTO club_roles (role_name)
VALUES ('Organizer'), ('Moderator'), ('Reader');


DO
$$
DECLARE
    club_rec RECORD;
    cnt INT;
BEGIN
    FOR club_rec IN SELECT club_id FROM book_clubs LOOP
        FOR cnt IN 1..((floor(random() * 5))::int + 1) LOOP  -- от 1 до 5 встреч
            INSERT INTO meetings (club_id, meeting_topic, description, start_time, end_time, status)
            VALUES (
                club_rec.club_id,
                'Meeting ' || cnt,
                'Discussion of book ' || cnt,
                CURRENT_TIMESTAMP - (floor(random() * 100))::int * interval '1 day',
                CURRENT_TIMESTAMP - (floor(random() * 100))::int * interval '1 day' + interval '1 hour',
                CASE WHEN random() > 0.5 THEN 'Planned' ELSE 'Completed' END
            );
        END LOOP;
    END LOOP;
END
$$;


INSERT INTO reader_club_roles (reader_id, club_id, role_id)
SELECT reader_id, club_id, role_id
FROM (
    SELECT r.reader_id, b.club_id, c.role_id, random() as rnd
    FROM readers r
    CROSS JOIN book_clubs b
    CROSS JOIN club_roles c
) t
ORDER BY rnd
LIMIT 300;

DO
$$
DECLARE
    meet_rec RECORD;
    i INT;
BEGIN
    FOR meet_rec IN SELECT meeting_id FROM meetings LOOP
        FOR i IN 1..10 LOOP
            INSERT INTO attendance_history (reader_id, meeting_id, attendance_status, attendance_date)
            VALUES (
                (SELECT reader_id FROM readers ORDER BY random() LIMIT 1),
                meet_rec.meeting_id,
                CASE WHEN random() > 0.3 THEN 'Present' ELSE 'Absent' END,
                CURRENT_DATE - (floor(random() * 30))::int  -- до 30 дней назад
            );
        END LOOP;
    END LOOP;
END
$$;
