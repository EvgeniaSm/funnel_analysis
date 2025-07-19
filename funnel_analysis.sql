-- Funnel Analysis: Booking Funnel

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

"""-- Funnel Step Analysis: Signup > App Open > Search > Booking > Completed

WITH signup AS (
  SELECT user_id, MIN(event_time) AS signup_time
  FROM events
  WHERE event_type = 'signup'
  GROUP BY user_id
),
app_open AS (
  SELECT user_id, MIN(event_time) AS app_open_time
  FROM events
  WHERE event_type = 'app_open'
  GROUP BY user_id
),
search AS (
  SELECT user_id, MIN(event_time) AS search_time
  FROM events
  WHERE event_type = 'search'
  GROUP BY user_id
),
booking AS (
  SELECT user_id, MIN(event_time) AS booking_time
  FROM events
  WHERE event_type = 'booking'
  GROUP BY user_id
),
completed AS (
  SELECT user_id, MIN(event_time) AS completed_time
  FROM events
  WHERE event_type = 'completed'
  GROUP BY user_id
)

SELECT
  COUNT(DISTINCT s.user_id) AS signup_users,
  COUNT(DISTINCT ao.user_id) AS app_open_users,
  COUNT(DISTINCT sr.user_id) AS search_users,
  COUNT(DISTINCT b.user_id) AS booking_users,
  COUNT(DISTINCT c.user_id) AS completed_users,
  ROUND(COUNT(DISTINCT ao.user_id) * 100.0 / COUNT(DISTINCT s.user_id), 1) AS app_open_rate,
  ROUND(COUNT(DISTINCT sr.user_id) * 100.0 / COUNT(DISTINCT ao.user_id), 1) AS search_rate,
  ROUND(COUNT(DISTINCT b.user_id) * 100.0 / COUNT(DISTINCT sr.user_id), 1) AS booking_rate,
  ROUND(COUNT(DISTINCT c.user_id) * 100.0 / COUNT(DISTINCT b.user_id), 1) AS completion_rate
FROM signup s
LEFT JOIN app_open ao ON s.user_id = ao.user_id
LEFT JOIN search sr ON s.user_id = sr.user_id
LEFT JOIN booking b ON s.user_id = b.user_id
LEFT JOIN completed c ON s.user_id = c.user_id;
""",

    "insights.md": """# 📈 Business Insights & Interpretation

## 🔍 What this analysis shows:
- Overall funnel performance across five key user actions
- Drop-off points (e.g. users signing up but never booking)
- Key optimization areas in the user journey

## 🧠 Potential insights:
- High drop-off between signup and app_open? → onboarding friction
- Many users search but don't book? → pricing, availability, UX
- High booking-to-completion drop? → cancellation reasons, failed payments

This type of analysis supports product, UX and operations teams in optimizing the user journey and increasing booking success rates.
"""
