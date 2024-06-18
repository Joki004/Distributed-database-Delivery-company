USE DC_Warehouse;
GO

CREATE OR ALTER PROCEDURE DELIVER_PACKAGE
    @package_id INT
AS
BEGIN
	DECLARE @action_message VARCHAR(350);
	DECLARE @current_datetime DATETIME = GETDATE();

	IF NOT EXISTS (SELECT * FROM Package WHERE @package_id = package_id)
    BEGIN
        RAISERROR('Package with id: %d does not exist in the database.', 16, 1, @package_id);
        RETURN;
    END

    UPDATE PACKAGE
    SET status = 'DELIVERED'
    WHERE package_id = @package_id;

	SET @action_message = 'DELIVERED';

	INSERT INTO PackageHistory (package_id, action, action_date)
    VALUES (@package_id, @action_message, @current_datetime);
END;
GO
