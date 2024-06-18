USE DC_Warehouse;
GO

CREATE OR ALTER PROCEDURE ADD_PACKAGE
    @warehouse_id INT,
    @customer_id INT,
	@final_warehouse_id INT,
    @type VARCHAR(50),
    @size VARCHAR(50),
    @weight DECIMAL(10, 2)
AS
BEGIN
    DECLARE @package_id INT;
    DECLARE @warehouse_name VARCHAR(100);
    DECLARE @action_message VARCHAR(350);
    DECLARE @current_datetime DATETIME = GETDATE();
	DECLARE @expected_delivery_date DATETIME = GETDATE();
	IF NOT EXISTS (SELECT * FROM [DC_Customer].dbo.Customer WHERE @customer_id = customer_id)
    BEGIN
        RAISERROR('Customer with id: %d does not exist in the database.', 16, 1, @customer_id);
        RETURN;
    END

	IF NOT EXISTS (SELECT * FROM Warehouse WHERE @warehouse_id = warehouse_id)
    BEGIN
        RAISERROR('Warehouse with id: %d does not exist in the database.', 16, 1, @warehouse_id);
        RETURN;
    END

    SELECT @warehouse_name = warehouse_name
    FROM Warehouse
    WHERE warehouse_id = @warehouse_id;

    SET @action_message = 'PACKAGE HAS BEEN MOVED FROM CLIENT_ID: ' + CAST(@customer_id AS VARCHAR(10)) + ' TO WAREHOUSE: ' + @warehouse_name;

    INSERT INTO Package (warehouse_id, customer_id, step_number, status, ExpectedDeliveryDate)
    VALUES (@warehouse_id, @customer_id,1, 'IN WAREHOUSE', DATEADD(DAY, 7, @expected_delivery_date)); --Calculate expected delivery date

    SET @package_id = SCOPE_IDENTITY();

    INSERT INTO PackageDetails (package_id, type, size, weight)
    VALUES (@package_id, @type, @size, @weight);

    INSERT INTO PackageHistory (package_id, action, action_date)
    VALUES (@package_id, @action_message, @current_datetime);

	EXEC [DC_Customer].[dbo].[ORACLE_CREATE_BEST_ITINERARY] @warehouse_id,@final_warehouse_id,@package_id;
END;
GO
