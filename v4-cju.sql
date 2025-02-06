
  /*Запрос с использованием CTE:
     Список книжных клубов и количество читателей, связанных с каждым клубом.
     Сначала в CTE "reader_counts" подсчитывается число уникальных читателей
     для каждого клубa, затем результат объединяется с таблицей book_clubs.*/
WITH reader_counts AS (
    SELECT club_id, 
           COUNT(DISTINCT reader_id) AS reader_count
    FROM reader_club_roles
    GROUP BY club_id
)
SELECT 
    bc.club_id,
    bc.club_name,
    COALESCE(rc.reader_count, 0) AS reader_count
FROM book_clubs bc
LEFT JOIN reader_counts rc ON bc.club_id = rc.club_id;



  /* Запрос с использованием JOIN:
     Список читателей и их встреч по книжным клубам.
     Выводятся имя, фамилия читателя, название клуба, тема встречи и статус встречи.*/

SELECT 
    r.first_name,
    r.last_name,
    bc.club_name,
    m.meeting_topic,
    m.status
FROM readers r
JOIN reader_club_roles rcr ON r.reader_id = rcr.reader_id
JOIN book_clubs bc ON rcr.club_id = bc.club_id
JOIN meetings m ON bc.club_id = m.club_id
ORDER BY r.last_name, bc.club_name, m.meeting_topic;


/* Запрос с использованием UNION ALL:
     Объединение списка читателей и списка ролей клуба.
     */
SELECT 
    r.reader_id AS id,
    r.first_name || ' ' || r.last_name AS full_name,
    'Reader' AS record_type
FROM readers r
UNION ALL
SELECT 
    cr.role_id AS id,
    cr.role_name AS full_name,
    'Role' AS record_type
FROM club_roles cr;
