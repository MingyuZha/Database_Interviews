CREATE FUNCTION getNthHighestSalary (N INT) RETURNS INT
BEGIN
SET N = N-1;
RETURN (SELECT DISTINCT Salary FROM Employee ORDER BY Salary DESC Limit N, 1);
END