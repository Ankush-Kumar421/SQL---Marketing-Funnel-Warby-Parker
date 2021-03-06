--For this project, we wil be building funnels from a single table and multiple tables and comparing funnels for A/B Tests.


--Quiz Funnel 

SELECT *
FROM survey
LIMIT 10;

-- Create a funnel from a single funnel and determine what is the number of responses for each question? Note this is also analyzing How many users move from Question 1 to Question 2, etc. 

SELECT 
  question AS 'Questions',
  COUNT(DISTINCT user_id) AS 'Total Number of Responses'
FROM survey
GROUP BY 1;


-- Home Try-On Funnel

SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

--Warby Parker's funnel process is: Take the Style Quiz -> Home Try On -> Purchase the Perfect Pair of Glasses. We combined three tables below into a funnel table so we can analyze it. Each row will represent a single user.
  -- If the user has any entries in home try, then is_home_entry_on will be True indicated by "1".
  -- If the user has any entries in purchase, then is_purchase will be True.

SELECT 
  DISTINCT q.user_id,
  h.user_id IS NOT NULL AS 'is_home_entry_on',
  h.number_of_pairs, 
  p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz AS 'q'
LEFT JOIN home_try_on AS 'h'
  ON q.user_id = h.user_id
LEFT JOIN purchase AS 'p'
  ON q.user_id = p.user_id
LIMIT 10;

-- Let’s query from this funnels table and calculate overall conversion rates. Then lets add the following calculation to analyze more in depth: 
  -- 1) Percentage of users from quiz to home trial
  -- 2) Percentage of users from home trial to purchase

WITH funnels AS (SELECT 
  DISTINCT q.user_id,
  h.user_id IS NOT NULL AS 'is_home_entry_on',
  h.number_of_pairs, 
  p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz AS 'q'
LEFT JOIN home_try_on AS 'h'
  ON q.user_id = h.user_id
LEFT JOIN purchase AS 'p'
  ON q.user_id = p.user_id)
SELECT
  COUNT(*) AS 'num_quiz',
  SUM(is_home_entry_on) AS 'num_trial',
  SUM(is_purchase) AS 'num_purchase',
  1.0 * SUM(is_home_entry_on) / COUNT(user_id) AS 'quiz_to_trial',
  1.0 * SUM(is_purchase) / SUM(is_home_entry_on) AS 'trial_to_purchase'
FROM funnels;


-- We will conduct an A/B Test to find out whether or not users who get more pairs to try on at home will be more likely to make a purchase.
  -- 50% of the users will get 3 pairs to try on.
  -- 50% of the users will get 5 pairs to try on.

WITH funnels AS (SELECT 
  DISTINCT q.user_id,
  h.user_id IS NOT NULL AS 'is_home_entry_on',
  h.number_of_pairs, 
  p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz AS 'q'
LEFT JOIN home_try_on AS 'h'
  ON q.user_id = h.user_id
LEFT JOIN purchase AS 'p'
  ON q.user_id = p.user_id)
SELECT
  number_of_pairs AS 'AB_variant',
  SUM(is_home_entry_on) AS 'home_trial',
  SUM(is_purchase) AS 'num_purchase'
FROM funnels
WHERE number_of_pairs IS NOT NULL
GROUP BY 1;


-- Other analysis based on original tables

-- Most common style customer selected from the quiz.
SELECT style,
  COUNT(*) AS 'Type Selected'
FROM quiz
GROUP BY 1
ORDER BY 1 DESC;

-- Most common style users actually purchased.
SELECT style,
  COUNT(*) AS 'Type Selected'
FROM purchase
GROUP BY 1
ORDER BY 1 DESC;

-- Most popular model sold.
SELECT
  model_name,
  COUNT(model_name) AS 'qty_sold'
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;

-- Maximum and minimum price for eyeglasses.
SELECT
  MAX(price),
  MIN(price)
FROM purchase;







