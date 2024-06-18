--EMPLOYEES
USE DC_Customer;
GO
CREATE OR ALTER PROCEDURE ORACLE_INSERT_EMPLOYEE
    @EmployeeName VARCHAR(100),
    @Position VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @EmployeeNameEscaped NVARCHAR(100);
    DECLARE @PositionEscaped NVARCHAR(100);

    SET @EmployeeNameEscaped = REPLACE(@EmployeeName, '''', '''''');
    SET @PositionEscaped = REPLACE(@Position, '''', '''''');

    SET @SQL = N'BEGIN EMPLOYEE_PACKAGE.INSERT_EMPLOYEE(''' + @EmployeeNameEscaped + ''', ''' + @PositionEscaped + '''); END;';

	EXEC (@SQL) AT OracleDB;

    PRINT 'Employee inserted successfully into Oracle database.';
END;
GO