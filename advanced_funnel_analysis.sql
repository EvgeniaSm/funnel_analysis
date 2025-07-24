-- Advanced Funnel Analysis: Signup → Search → Booking
WITH base_events AS (
    SELECT
        user_id,
        event_type,
        event_time,
        -- example columns for segmentation (optional)
        device_type,
        city
    FROM events
    WHERE event_type IN ('signup', 'search', 'booking')
),

-- Step timestamps per user
user_steps AS (
    SELECT
        user_id,
        MIN(CASE WHEN event_type = 'signup' THEN event_time END) AS signup_time,
        MIN(CASE WHEN event_type = 'search' THEN event_time END) AS search_time,
        MIN(CASE WHEN event_type = 'booking' THEN event_time END) AS booking_time,
        MAX(device_type) AS device_type,
        MAX(city) AS city
    FROM base_events
    GROUP BY user_id
),

-- Conversion flags & timing
funnel_metrics AS (
    SELECT
        user_id,
        signup_time,
        search_time,
        booking_time,
        device_type,
        city,
        CASE WHEN search_time IS NOT NULL THEN 1 ELSE 0 END AS did_search,
        CASE WHEN booking_time IS NOT NULL THEN 1 ELSE 0 END AS did_book,
        CASE WHEN search_time IS NOT NULL AND booking_time IS NOT NULL THEN 1 ELSE 0 END AS full_funnel,
        DATE_TRUNC('week', signup_time) AS signup_week,
        EXTRACT(EPOCH FROM (search_time - signup_time))/60 AS min_to_search,
        EXTRACT(EPOCH FROM (booking_time - search_time))/60 AS min_to_book
    FROM user_steps
)

-- Final metrics
SELECT
    signup_week,
    COUNT(*) AS signed_up,
    SUM(did_search) AS searched,
    SUM(did_book) AS booked,
    SUM(full_funnel) AS full_funnel_completed,
    ROUND(SUM(did_search)*100.0 / COUNT(*), 1) AS search_rate,
    ROUND(SUM(did_book)*100.0 / NULLIF(SUM(did_search), 0), 1) AS booking_rate,
    ROUND(SUM(full_funnel)*100.0 / COUNT(*), 1) AS full_funnel_rate,
    ROUND(AVG(min_to_search), 1) AS avg_min_to_search,
    ROUND(AVG(min_to_book), 1) AS avg_min_to_book
FROM funnel_metrics
GROUP BY signup_week
ORDER BY signup_week DESC;
