CREATE OR REPLACE 
PACKAGE EMPLOYEE_PACKAGE AS 

   PROCEDURE InsertEmployee (
        I_EmployeeName IN VARCHAR2,
        I_Position IN VARCHAR2
    );

END EMPLOYEE_PACKAGE;
/