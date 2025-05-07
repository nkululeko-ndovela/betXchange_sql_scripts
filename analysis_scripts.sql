 --1. Clean & Standardize Date Format in users Table

UPDATE users
SET registration_date = TO_DATE(registration_date, 'YYYY/MM/DD')
WHERE registration_date ~ '^\d{4}/\d{2}/\d{2}$';

--2. Summarize Total Transaction Activity Per User

SELECT 
  user_id,
  COUNT(*) AS total_transactions,
  SUM(price_total) AS total_spent,
  SUM(paid_out) AS total_payout,
  SUM(win_total) AS total_wins
FROM transactions
WHERE resolve_time_day != 'Total'
GROUP BY user_id;

-- 3. Monthly Betting Trends

SELECT 
  DATE_TRUNC('month', resolve_time_day::date) AS month,
  SUM(price_total) AS total_bet,
  SUM(paid_out) AS total_payout,
  SUM(win_total) AS total_win
FROM transactions
WHERE resolve_time_day != 'Total'
GROUP BY month
ORDER BY month;

--4.1 Identify Duplicate Users and Remove them

SELECT user_id, COUNT(*) AS occurrences
FROM users
GROUP BY user_id
HAVING COUNT(*) > 1;
4.2--
DELETE FROM users
WHERE ctid IN (
  SELECT ctid
  FROM (
    SELECT ctid,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY registration_date DESC) AS rn
    FROM users
  ) sub
  WHERE rn > 1
);


--5. Average Win Rate by Age Group

SELECT 
  CASE 
    WHEN age < 30 THEN 'Under 30'
    WHEN age BETWEEN 30 AND 44 THEN '30–44'
    ELSE '45+'
  END AS age_group,
  AVG(t.win_total) AS avg_win
FROM users u
JOIN transactions t ON u.user_id = t.user_id
WHERE resolve_time_day != 'Total'
GROUP BY age_group;

--6. Daily Slip Trends for SPORTS Category

SELECT 
  resolve_time_day::int AS day,
  SUM(CAST(sport AS INT)) AS total_sport_slips
FROM slips
WHERE resolve_time_day != 'Total'
GROUP BY resolve_time_day
ORDER BY day;


-- 7. Top Countries by Number of Users

SELECT country, COUNT(*) AS user_count
FROM users
GROUP BY country
ORDER BY user_count DESC
LIMIT 10;
--8. Event Count Trends (Nth Day Web Traffic)

SELECT 
  nth_day::int,
  SUM(event_count) AS total_events
FROM web_traffic
GROUP BY nth_day
ORDER BY nth_day;


--9. Highest Spending Users

SELECT 
  user_id,
  SUM(price_total) AS total_spent
FROM transactions
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;

--10. Slip Category Popularity

SELECT
  'AVIATOR' AS category, SUM(CAST(aviator AS INT)) AS total FROM slips
UNION ALL
SELECT 'BETGAMES', SUM(CAST(betgames AS INT)) FROM slips
UNION ALL
SELECT 'CASINO', SUM(CAST(casino AS INT)) FROM slips
UNION ALL
SELECT 'HORSE RACING', SUM(CAST(horse_racing AS INT)) FROM slips
UNION ALL
SELECT 'LOTTO', SUM(CAST(lotto AS INT)) FROM slips
UNION ALL
SELECT 'SPORT', SUM(CAST(sport AS INT)) FROM slips;
