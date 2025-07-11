-- get expense analysis report
SELECT vendor_name
      ,sum(amount) as total_spent

FROM Expense

GROUP BY vendor_name
ORDER BY vendor_name ASC;