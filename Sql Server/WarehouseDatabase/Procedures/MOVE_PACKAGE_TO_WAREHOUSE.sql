USE DC_Warehouse;
GO

CREATE OR ALTER PROCEDURE MOVE_PACKAGE_TO_WAREHOUSE
    @package_id INT
AS
BEGIN
    DECLARE @current_date DATETIME = GETDATE();
    DECLARE @warehouse_name VARCHAR(100);
    DECLARE @vehicle_id INT;
	DECLARE @package_details_id INT;
	DECLARE @step_number INT;
	DECLARE @warehouse_id INT;
	DECLARE @warehouse_id_actual INT;
	IF NOT EXISTS (SELECT * FROM Package WHERE package_id = @package_id)
    BEGIN
        RAISERROR('Package with id: %d does not exist in the database.', 16, 1, @package_id);
        RETURN;
    END
	SELECT @package_details_id = pd.package_details_id, @step_number = p.step_number
    FROM Package p
    JOIN PackageDetails pd ON p.package_id = pd.package_id
    WHERE p.package_id = @package_id;
	
	 SELECT @warehouse_id_actual=R.from_warehouse_id , @warehouse_id = R.to_warehouse_id
    FROM [OracleDB]..SCOTT.ITINERARY IT 
    JOIN [OracleDB]..SCOTT.ROUTE R ON R.route_id = IT.route_id
    WHERE @step_number = IT.step_number AND IT.package_details_id = @package_details_id
	
	 IF @warehouse_id IS NULL
    BEGIN
		UPDATE Package
		SET status = 'Delivered',step_number = -1
		WHERE package_id = @package_id;
        PRINT 'No more steps in the itinerary.';
        RETURN;
    END
	IF NOT EXISTS (SELECT * FROM Warehouse WHERE warehouse_id = @warehouse_id)
    BEGIN
        RAISERROR('Warehouse with id: %d does not exist in the database.', 16, 1, @warehouse_id);
        RETURN;
    END
    SELECT @warehouse_name = w.warehouse_name
    FROM Warehouse w
    WHERE w.warehouse_id = @warehouse_id;
    SELECT @vehicle_id = v.vehicle_id
    FROM Package p
    LEFT JOIN VehicleInventory vi ON p.package_id = vi.package_id
    LEFT JOIN Vehicle v ON vi.vehicle_id = v.vehicle_id
    WHERE p.package_id = @package_id;

	DELETE FROM VehicleInventory Where 
	package_id = @package_id

    UPDATE Package
    SET status = 'In Warehouse', warehouse_id = @warehouse_id, vehicle_id = NULL,step_number = @step_number+1
    WHERE package_id = @package_id;

    INSERT INTO PackageHistory (package_id, action, action_date)
    VALUES (@package_id, 'PACKAGE HAS BEEN MOVED FROM VEHICLE: ' + CAST(@vehicle_id AS VARCHAR(10)) + ' TO WAREHOUSE: ' + @warehouse_name, @current_date);
END;
GO