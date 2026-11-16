SELECT DATE_TRUNC('day',aa.adoption_date) as adoption_date
      ,d.name
      ,STRING_AGG(b.breed_name, '/' ORDER BY b.breed_name) AS breed
      ,d.sex
      ,aa.adoption_fee
      ,d.surrender_date
      ,(aa.adoption_date - d.surrender_date) as days_in_shelter

FROM Dog d
JOIN ApprovedApplication aa on d.dogID = aa.dogID
LEFT JOIN DogBreed db ON db.dogID = d.dogID
LEFT JOIN Breed b ON db.breedID = b.breedID

WHERE aa.adoption_date BETWEEN %s and %s
  AND (aa.adoption_date - d.surrender_date) >= INTERVAL '60 days'

GROUP BY aa.adoption_date, d.dogID, d.name, d.sex, aa.adoption_fee, d.surrender_date
ORDER BY aa.adoption_date ASC, d.name ASC;