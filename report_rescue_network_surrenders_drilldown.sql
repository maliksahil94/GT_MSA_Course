SELECT DATE_TRUNC('day',d.surrender_date) AS surrender_date
      ,d.name
      ,STRING_AGG(b.breed_name, '/' ORDER BY b.breed_name) AS breed
      ,d.sex
      ,d.additional_info
      ,d.surrenderer_phone
      ,d.microchipID AS microchip_id

FROM Dog d
LEFT JOIN DogBreed db ON db.dogID = d.dogID
LEFT JOIN Breed b ON db.breedID = b.breedID

WHERE d.rescue_network = 'TRUE'
  AND d.surrender_date BETWEEN %s and %s

GROUP BY d.dogID, d.name, d.sex, d.additional_info, d.surrender_date, d.microchipID
ORDER BY d.surrender_date ASC, d.name ASC;