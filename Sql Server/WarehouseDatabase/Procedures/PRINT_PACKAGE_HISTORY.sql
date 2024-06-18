USE DC_Warehouse;
GO

CREATE OR ALTER PROCEDURE PRINT_PACKAGE_HISTORY
    @package_id INT
AS
BEGIN
    DECLARE @package_history_id INT;
    DECLARE @action VARCHAR(250);
    DECLARE @action_date DATETIME;

	IF NOT EXISTS (SELECT * FROM Package WHERE package_id = @package_id)
    BEGIN
        RAISERROR('Package with id: %d does not exist in the database.', 16, 1, @package_id);
        RETURN;
    END

    DECLARE package_history_cursor CURSOR FOR
    SELECT package_history_id, action, action_date
    FROM PackageHistory
    WHERE package_id = @package_id
    ORDER BY action_date;

    PRINT 'History for package with id: ' + CAST(@package_id AS VARCHAR);

    OPEN package_history_cursor;

    FETCH NEXT FROM package_history_cursor INTO @package_history_id, @action, @action_date;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @action + ', Date: ' + CAST(@action_date AS VARCHAR);
        
        FETCH NEXT FROM package_history_cursor INTO @package_history_id, @action, @action_date;
    END;

    CLOSE package_history_cursor;
    DEALLOCATE package_history_cursor;
END;
GO