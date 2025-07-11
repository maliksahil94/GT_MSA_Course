SELECT p.first_name
      ,p.last_name
      ,u.emailID
      ,CASE WHEN EXTRACT(YEAR FROM AGE(%s, u.date_joined) > 0
             AND EXTRACT(YEAR FROM AGE(%s, u.date_joined)) % 5 = 0
             THEN 'Yes' ELSE 'No' END AS milestone

FROM "User" u
JOIN Person p on u.emailID = p.emailID

WHERE u.role = 'Volunteer'
  AND EXTRACT(MONTH FROM u.date_joined) = %s
  AND EXTRACT(YEAR FROM u.date_joined) = %s;
