Select w1.Id
From Weather w1, Weather w2
Where w1.Temperature > w2.Temperature 
      AND DATEDIFF(w1.RecordDate, w2.RecordDate) = 1;