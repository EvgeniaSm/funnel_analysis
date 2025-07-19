-- Sample Funnel Analysis: Booking Funnel

WITH step_1 AS (
    SELECT user_id, MIN(event_time) AS signup_time
    FROM events
    WHERE event_type = 'signup'
    GROUP BY user_id
),
step_2 AS (
    SELECT user_id, MIN(event_time) AS search_time
    FROM events
    WHERE event_type = 'search'
    GROUP BY user_id
),
step_3 AS (
    SELECT user_id, MIN(event_time) AS booking_time
    FROM events
    WHERE event_type = 'booking'
    GROUP BY user_id
)

SELECT
    COUNT(DISTINCT s1.user_id) AS signed_up,
    COUNT(DISTINCT s2.user_id) AS searched,
    COUNT(DISTINCT s3.user_id) AS booked,
    ROUND(COUNT(DISTINCT s2.user_id) * 100.0 / COUNT(DISTINCT s1.user_id), 1) AS search_rate,
    ROUND(COUNT(DISTINCT s3.user_id) * 100.0 / COUNT(DISTINCT s2.user_id), 1) AS booking_rate
FROM step_1 s1
LEFT JOIN step_2 s2 ON s1.user_id = s2.user_id
LEFT JOIN step_3 s3 ON s1.user_id = s3.user_id
;
