SELECT Email 
From Person
GROUP BY Email
HAVING COUNT(Id) > 1