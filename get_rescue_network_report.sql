-- get_rescue_network_report
WITH Months 
AS
(
SELECT generate_series(
                      (CURRENT_DATE - INTERVAL '5 months')::date,
                      CURRENT_DATE,
            		  '1 month'
                      )::date as month_start

),

MonthlyData
AS 
(
SELECT TO_CHAR(m.month_start, 'YYYY-MM') AS month_key
      ,TO_CHAR(m.month_start, 'Mon YYYY') AS display_month

      ,COUNT(DISTINCT CASE WHEN d.rescue_network = TRUE AND DATE_TRUNC('month', d.surrender_date) = m.month_start THEN d.dogID END) AS rn_surrenders

      ,COUNT(DISTINCT CASE WHEN a.adoption_date IS NOT NULL AND DATE_TRUNC('month', a.adoption_date) = m.month_start 
      	                    AND (a.adoption_date - d.surrender_date) >= INTERVAL '60 days' 
      	                    THEN d.dogID END) AS adopted_60_plus_days
      
      ,COALESCE(SUM(CASE WHEN a.adoption_date IS NOT NULL AND DATE_TRUNC('month', a.adoption_date) = m.month_start 
      	                 THEN e.amount ELSE 0 END), 0) AS total_expenses_adopted_dogs
   

FROM Months m
LEFT JOIN Dog d on DATE_TRUNC('month',d.surrender_date) <= m.month_start
LEFT JOIN ApprovedApplication a ON d.dogID = a.dogID
                               AND DATE_TRUNC('month',a.adoption_date) = m.month_start
LEFT JOIN Expense e ON d.dogID = e.dogID
                   AND date_trunc('month',e.expense_date) = m.month_start

GROUP BY m.month_start
)

SELECT display_month as month
      ,rn_surrenders
      ,adopted_60_plus_days
      ,total_expenses_adopted_dogs as total_expenses

FROM MonthlyData

ORDER BY month_key DESC;