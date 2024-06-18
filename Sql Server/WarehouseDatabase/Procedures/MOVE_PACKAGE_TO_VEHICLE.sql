USE DC_Warehouse;
GO

CREATE OR ALTER PROCEDURE MOVE_PACKAGE_TO_VEHICLE
    @package_id INT,
    @vehicle_id INT
AS
BEGIN
    DECLARE @current_date DATETIME = GETDATE();
    DECLARE @warehouse_name VARCHAR(100);
    
	IF NOT EXISTS (SELECT * FROM Package WHERE package_id = @package_id)
    BEGIN
        RAISERROR('Package with id: %d does not exist in the database.', 16, 1, @package_id);
        RETURN;
    END

	IF NOT EXISTS (SELECT * FROM Vehicle WHERE vehicle_id = @vehicle_id)
    BEGIN
        RAISERROR('Vehicle with id: %d does not exist in the database.', 16, 1, @vehicle_id);
        RETURN;
    END

    SELECT @warehouse_name = w.warehouse_name
    FROM Warehouse w
    INNER JOIN Package p ON w.warehouse_id = p.warehouse_id
    WHERE p.package_id = @package_id;

	UPDATE Package
    SET status = 'In Transit', warehouse_id = null, vehicle_id = @vehicle_id
    WHERE package_id = @package_id;

    INSERT INTO VehicleInventory (vehicle_id, package_id)
    VALUES (@vehicle_id, @package_id);

    INSERT INTO PackageHistory (package_id, action, action_date)
    VALUES (@package_id, 'PACKAGE HAS BEEN MOVED TO VEHICLE: ' + CAST(@vehicle_id AS VARCHAR(10)) + ' FROM WAREHOUSE: ' + @warehouse_name, @current_date);
END;
GO