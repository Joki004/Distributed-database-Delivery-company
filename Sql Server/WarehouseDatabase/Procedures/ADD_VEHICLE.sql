USE DC_Warehouse;
GO

CREATE OR ALTER PROCEDURE ADD_VEHICLE
    @employee_id INT
AS
BEGIN


    INSERT INTO Vehicle (employee_id)
    VALUES (@employee_id);
END;
GO