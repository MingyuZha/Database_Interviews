## Use IN operation
SELECT Name AS 'Customers'
FROM Customers
WHERE Id NOT IN (SELECT DISTINCT CustomerId FROM Orders)

## Use JOIN operation
SELECT Name AS 'Customers'
FROM Customers
LEFT JOIN Orders ON Customers.Id = Orders.CustomerId
WHERE Orders.Id IS NULL