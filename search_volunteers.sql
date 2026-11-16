SELECT p.first_name
      ,p.last_name
      ,u.emailID
      ,p.phone_number

FROM "User" U
JOIN Person p on u.emailID = p.emailID

WHERE u.role = 'Volunteer'
  AND (
       LOWER(p.first_name) LIKE %s OR
       LOWER(p.last_name) LIKE %s
  	  )

ORDER BY p.last_name asc,
         p.first_name asc;