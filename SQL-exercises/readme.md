# SQL Syntax
## 目录
* [SELECT TOP/LIMIT](#select-toplimit)
* [LIKE](#like)
* [Wildcard Characters in SQL Server](#wildcard-characters-in-sql-server)
* [IN](#in)
* [BETWEEN](#between)
* [JOIN](#join)
* [GROUP BY](#group-by)
* [HAVING](#having)
* [EXISTS](#exists)
* [UNION](#union)
* [ANY, ALL](#any-all)
* [IFNULL](#ifnull)
* [NULL](#null)
## SELECT TOP/LIMIT

The SELECT TOP clause is used to specify the number of records to return.

The SELECT TOP clause is useful on large tables with thousands of records. Returning a large number of records can impact on performance.

In **MySql**, we use ```LIMIT``` Clause instead.

```mysql
SELECT * FROM Customers
WHERE Country='Germany'
LIMIT 3;
```

```LIMIT```还有一种用法：Returning a range of rows from a table called employee (starting at record 2, return the next 4 rows)

```mysql
select * from employee limit 2,4
```

## LIKE

The LIKE operator is used in a WHERE clause to search for a specified pattern in a column.

There are two wildcards often used in conjunction with the LIKE operator:

- % - The percent sign represents **zero, one, or multiple** characters
- _ - The underscore represents a single character

```mysql
SELECT * FROM Customers
WHERE CustomerName LIKE 'a_%_%';
```

## Wildcard Characters in SQL Server

| **Symbol** | Description                                         | **Example**                              |
| ---------- | --------------------------------------------------- | ---------------------------------------- |
| %          | Represents zero or more characters                  | bl% finds bl, black, blue, and blob      |
| _          | Represents a single character                       | h_t finds hot, hat, and hit              |
| []         | Represents any single character within the brackets | h[oa]t finds hot and hat, but not hit    |
| ^          | Represents any character not in the brackets        | h\[^oa\]t finds hit, but not hot and hat |
| -          | Represents a range of characters                    | c[a-b]t finds cat and cbt                |

## IN

The IN operator allows you to specify multiple values in a WHERE clause.

The IN operator is a shorthand for multiple OR conditions.

```mysql
SELECT * FROM Customers
WHERE Country IN (SELECT Country FROM Suppliers);
```

## BETWEEN

The BETWEEN operator selects values within a given range. The values can be **numbers, text, or dates**.

The BETWEEN operator is **inclusive**: begin and end values are included. 

* Numbers:

```mysql
SELECT * FROM Products
WHERE Price NOT BETWEEN 10 AND 20;
```

* Text:

```mysql
SELECT * FROM Products
WHERE ProductName BETWEEN "Carnarvon Tigers" AND "Chef Anton's Cajun Seasoning"
ORDER BY ProductName;
```

* Dates:

```mysql
SELECT * FROM Orders
WHERE OrderDate BETWEEN '1996-07-01' AND '1996-07-31';
```

## JOIN

1. **INNER JOIN:** Returns records that have matching values in both tables

![img](https://www.w3schools.com/sql/img_innerjoin.gif)

```mysql
SELECT column_name(s)
FROM table1
INNER JOIN table2
ON table1.column_name = table2.column_name;
```



2. **LEFT JOIN: **Return all records from the left table, and the matched records from the right table

![img](https://www.w3schools.com/sql/img_leftjoin.gif)

> **Note:** The LEFT JOIN keyword returns all records from the left table, even if there are no matches in the right table.

3. **RIGHT JOIN:** Return all records from the right table, and the matched records from the left table

![img](https://www.w3schools.com/sql/img_rightjoin.gif)

4. **FULL JOIN:** Return all records when there is a match in either left or right table

![img](https://www.w3schools.com/sql/img_fulljoin.gif)

## GROUP BY

The GROUP BY statement is often used with **aggregate functions** (```COUNT```, ```MAX```, ```MIN```, ```SUM```, ```AVG```) to group the result-set by one or more columns.

```mysql
SELECT COUNT(CustomerID), Country
FROM Customers
GROUP BY Country;
```

## HAVING

The HAVING clause was added to SQL because the WHERE keyword could not be used with aggregate functions.

```mysql
SELECT COUNT(CustomerID), Country
FROM Customers
GROUP BY Country
HAVING COUNT(CustomerID) > 5
ORDER BY COUNT(CustomerID) DESC;
```

## EXISTS

The EXISTS operator is used to test for the existence of any record in a subquery.

The EXISTS operator returns **true** if the subquery returns **one or more** records.

```mysql
SELECT SupplierName
FROM Suppliers
WHERE EXISTS (SELECT ProductName FROM Products WHERE SupplierId = Suppliers.supplierId AND Price < 20);
```

## UNION

The UNION operator is used to combine the result-set of two or more SELECT statements.

- Each SELECT statement within UNION **must** have the same number of columns
- The columns must also have similar data types
- The columns in each SELECT statement must also be in the same order

```mysql
SELECT City FROM Customers
UNION
SELECT City FROM Suppliers
ORDER BY City;
```

>  **Note:** The UNION operator selects only distinct values by default. To allow duplicate values, use UNION ALL:

```mysql
SELECT City FROM Customers
UNION ALL
SELECT City FROM Suppliers
ORDER BY City;
```

## ANY, ALL

The ANY and ALL operators are used with a WHERE or HAVING clause.

The ANY operator returns true if any of the subquery values meet the condition.

The ALL operator returns true if all of the subquery values meet the condition.

The following SQL statement returns TRUE and lists the product names if it finds **ANY** records in the OrderDetails table that quantity = 10:

```mysql
SELECT ProductName
FROM Products
WHERE ProductID = ANY (SELECT ProductID FROM OrderDetails WHERE Quantity = 10);
```

The following SQL statement returns TRUE and lists the productnames if **ALL** the records in the OrderDetails table has quantity = 10:

```mysql
SELECT ProductName
FROM Products
WHERE ProductID = ALL (SELECT ProductID FROM OrderDetails WHERE Quantity = 10);
```

## IFNULL

The MySQL ```IFNULL()``` function lets you return an alternative value if an expression is NULL:

```mysql
SELECT ProductName, UnitPrice * (UnitsInStock + IFNULL(UnitsOnOrder, 0))
FROM Products
```

## NULL

We will have to use the IS NULL and IS NOT NULL operators to test for NULL Values.

```mysql
SELECT CustomerName, ContactName, Address
FROM Customers
WHERE Address IS NULL;
```

## OFFSET

- OFFSET excludes the first set of records.
- OFFSET can **only** be used with an ```ORDER BY``` clause.

The general syntax to exclude first n records is: 

```mysql
SELECT column-names
  FROM table-name
 ORDER BY column-names
OFFSET n ROWS
```

To exclude first n records and return only the next m records:

```mysql
SELECT column-names
  FROM table-name
 ORDER BY column-names
OFFSET n ROWS
 FETCH NEXT m ROWS ONLY
```

This will return only record (n + 1) to (n + 1 + m).

## CREATE FUNCTION

```CREATE FUNCTION``` Syntax:

```mysql
CREATE FUNCTION func_name (v Data_type) RETURNS Data_type
BEGIN
DECLARE tmp_v Data_type
SET tmp_v = some operation;
RETURN (SELECT ... FROM ... WHERE ...);
END
```

