USE DC_Customer;
GO

CREATE OR ALTER PROCEDURE PRINT_CUSTOMER_INFORMATION
    @customer_id INT
AS
BEGIN
    DECLARE @first_name NVARCHAR(50);
    DECLARE @last_name NVARCHAR(50);
    DECLARE @email NVARCHAR(50);
    DECLARE @number NVARCHAR(20);
    DECLARE @address NVARCHAR(255);

    IF NOT EXISTS (SELECT * FROM Customer WHERE customer_id = @customer_id)
    BEGIN
        RAISERROR('Customer with id: %d does not exist in the database.', 16, 1, @customer_id);
        RETURN;
    END

    SELECT @first_name = first_name,
           @last_name = last_name,
           @email = email,
           @number = number,
           @address = address
    FROM Customer
    WHERE customer_id = @customer_id;

    PRINT 'Customer Information:';
    PRINT '----------------------';
    PRINT 'Customer ID: ' + CAST(@customer_id AS NVARCHAR);
    PRINT 'First Name: ' + @first_name;
    PRINT 'Last Name: ' + @last_name;
    PRINT 'Email: ' + COALESCE(@email, '');
    PRINT 'Number: ' + COALESCE(@number, '');
    PRINT 'Address: ' + COALESCE(@address, '');

    DECLARE @package_id INT;
    DECLARE @warehouse_id INT;
    DECLARE @status NVARCHAR(100);
    DECLARE @expected_delivery_date DATE;
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
        SELECT package_id, warehouse_id, status, ExpectedDeliveryDate
        FROM DC_Warehouse.dbo.Package
        WHERE customer_id = ' + CAST(@customer_id AS NVARCHAR(10));

    PRINT 'Package Information:';

    DECLARE @cursor_query NVARCHAR(MAX);
    SET @cursor_query = '
        DECLARE package_cursor CURSOR FOR
        ' + @sql;

    EXEC sp_executesql @cursor_query;
    OPEN package_cursor;

    FETCH NEXT FROM package_cursor INTO @package_id, @warehouse_id, @status, @expected_delivery_date;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '----------------------';
        PRINT 'Package ID: ' + CAST(@package_id AS NVARCHAR);
        PRINT 'Warehouse ID: ' + CAST(@warehouse_id AS NVARCHAR);
        PRINT 'Status: ' + @status;
        PRINT 'Expected Delivery Date: ' + CONVERT(NVARCHAR, @expected_delivery_date, 120);

        FETCH NEXT FROM package_cursor INTO @package_id, @warehouse_id, @status, @expected_delivery_date;
    END;

    CLOSE package_cursor;
    DEALLOCATE package_cursor;
END;
GO
