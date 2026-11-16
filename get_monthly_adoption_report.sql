WITH SurrenderData AS (
    -- to get surrendered dog data
    SELECT
        DATE_TRUNC('month', d.surrender_date) AS reporting_month,
        STRING_AGG(b.breed_name, '/' ORDER BY b.breed_name) AS breed,
        COUNT(DISTINCT d.dogID) AS surrendered_count,
        0 AS adopted_count,
        0.0 AS total_expenses,
        0.0 AS total_adoption_fees,
        0.0 AS net_profit_contribution -- Net profit for surrenders is 0

    FROM Dog d
    LEFT JOIN DogBreed db ON db.dogID = d.dogID
    LEFT JOIN Breed b ON b.breedID = db.breedID
    WHERE DATE_TRUNC('month', d.surrender_date) between CURRENT_DATE - INTERVAL '13 months' AND CURRENT_DATE - INTERVAL '1 month'
    GROUP BY reporting_month , breed
    ORDER BY reporting_month asc, breed asc         
),


AdoptionData AS (

    SELECT
        DATE_TRUNC('month', aa.adoption_date) AS reporting_month,
        STRING_AGG(b.breed_name, '/' ORDER BY b.breed_name) AS breed,
        0.0 AS surrendered_count,
        COUNT(DISTINCT d.dogID) AS adopted_count,
        COALESCE(SUM(e.amount), 0.0) AS total_expenses,
        COALESCE(SUM(aa.adoption_fee), 0.0) AS total_adoption_fees,
        COALESCE(SUM(CASE WHEN d.rescue_network = FALSE THEN aa.adoption_fee - COALESCE(e.amount, 0.0) ELSE 0 END), 0.0) AS net_profit_contribution

    FROM Dog d
    JOIN ApprovedApplication aa ON aa.dogID = d.dogID
    LEFT JOIN DogBreed db ON db.dogID = d.dogID
    LEFT JOIN Breed b ON b.breedID = db.breedID

    WHERE DATE_TRUNC('month', aa.adoption_date) between CURRENT_DATE - INTERVAL '13 months' AND CURRENT_DATE - INTERVAL '1 month'
    GROUP BY reporting_month , breed
    ORDER BY reporting_month asc, breed asc    

),

CombinedMonthlyData AS (

    SELECT * FROM SurrenderData
    UNION ALL
    SELECT * FROM AdoptionData
),

SELECT TO_CHAR(reporting_month,'Mon YYYY') AS month
      ,breed
      ,SUM(surrendered_count) AS surrendered_count
      ,SUM(adopted_count) AS adopted_count
      ,SUM(total_expenses) AS total_expenses
      ,SUM(total_adoption_fees) AS total_adoption_fees
      ,SUM(net_profit_contribution) AS net_profit

FROM CombinedMonthlyData

GROUP BY reporting_month, breed
ORDER BY reporting_month asc, breed asc;