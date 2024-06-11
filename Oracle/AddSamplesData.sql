INSERT ALL
    INTO Employee (EmployeeID, EmployeeName, Position) VALUES (SYS_GUID(), 'John Manager', 'Logistics Manager')
    INTO Employee (EmployeeID, EmployeeName, Position) VALUES (SYS_GUID(), 'Jane Supervisor', 'Warehouse Supervisor')
SELECT * FROM dual;
/

SELECT * FROM Employee;
