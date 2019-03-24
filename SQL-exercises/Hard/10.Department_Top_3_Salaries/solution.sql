SELECT d.Name AS 'Department', e1.Name AS 'Employee', e1.Salary AS 'Salary'
FROM Employee e1
JOIN Department d ON e1.DepartmentId = d.Id
WHERE 3 > (SELECT COUNT(DISTINCT e2.Salary) 
          FROM Employee e2
          WHERE e1.Salary < e2.Salary
                AND e1.DepartmentId = e2.DepartmentId)