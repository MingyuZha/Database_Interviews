Select Request_at As 'Day', Round(SUM(CASE WHEN Status <> 'completed' THEN 1 ELSE 0 END)/Count(Status), 2) AS 'Cancellation Rate'
From Trips
Join Users On Trips.Client_id = Users.Users_Id
Where (Request_at Between '2013-10-01' And '2013-10-03') 
    And Banned = 'No'
Group By Request_at