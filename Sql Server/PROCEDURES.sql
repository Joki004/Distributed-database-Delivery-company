------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------PROCEDURES------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

--CUSTOMER
USE DC_DeliveryCustomer;
GO
CREATE PROCEDURE DC_DELIVERY_CUSTOMER_INSERT_CUSTOMER
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(50),
    @Number NVARCHAR(20),
    @Address NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Customer (first_name, last_name, email, number, address)
    VALUES (@FirstName, @LastName, @Email, @Number, @Address);
END;
GO

--DELIVERY
USE DC_DeliveryCustomer;
GO


CREATE OR ALTER PROCEDURE DC_DELIVERY_CUSTOMER_INSERT_DELIVERY
    @CustomerID INT,
    @OrderID INT,
    @Status VARCHAR(100),
	@DeliveryDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = @CustomerID)
    BEGIN
        RAISERROR('CustomerID %d does not exist in the DC_DeliveryCustomer database.', 16, 1, @CustomerID);
        RETURN;
    END

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Result INT;


    SET @SQL = N'SELECT @Result = COUNT(*) FROM OPENQUERY([serverSQL], ''SELECT 1 FROM [DC_WarehouseOrder].[dbo].[Order] WHERE OrderID = ' + CAST(@OrderID AS NVARCHAR(20)) + ''')';

    EXEC sp_executesql @SQL, N'@Result INT OUTPUT', @Result OUTPUT;

    IF @Result = 0
    BEGIN
        RAISERROR('OrderID %d does not exist in the DC_WarehouseOrder database.', 16, 1, @OrderID);
        RETURN;
    END

	 DECLARE @IsOrderCorrect INT;
    SET @SQL = N'SELECT @IsOrderCorrect = COUNT(*) FROM OPENQUERY([serverSQL], 
                  ''SELECT 1 FROM [DC_WarehouseOrder].[dbo].[Order] WHERE OrderID = ' + CAST(@OrderID AS NVARCHAR(20)) + ' AND CustomerID = ' + CAST(@CustomerID AS NVARCHAR(20)) + ''')';
    EXEC sp_executesql @SQL, N'@IsOrderCorrect INT OUTPUT', @IsOrderCorrect OUTPUT;

    IF @IsOrderCorrect = 0
    BEGIN
        RAISERROR('OrderID %d is not assigned to CustomerID %d.', 16, 1, @OrderID, @CustomerID);
        RETURN;
    END


    INSERT INTO Delivery (CustomerID, OrderID, DeliveryDate, Status)
    VALUES (@CustomerID, @OrderID, @DeliveryDate, @Status);
END;
GO


--Warehouse
USE DC_DeliveryCustomer;
GO
CREATE OR ALTER PROCEDURE DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE
    @WarehouseName VARCHAR(100),
    @Address VARCHAR(200),
    @IsRefrigerated BIT,
    @Capacity INT,
    @QuantityAvailable INT,
    @MinimumStockLevel INT,
    @MaximumStockLevel INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ParamDefinition NVARCHAR(MAX);

    SET @SQL = N'INSERT INTO OPENQUERY([serverSQL], 
                    ''SELECT WarehouseName, Address, IsRefrigerated, Capacity, QuantityAvailable, MinimumStockLevel, MaximumStockLevel 
                      FROM [DC_WarehouseOrder].dbo.Warehouse'')
                VALUES (@WarehouseName, @Address, @IsRefrigerated, @Capacity, @QuantityAvailable, @MinimumStockLevel, @MaximumStockLevel)';

    SET @ParamDefinition = N'@WarehouseName VARCHAR(100), 
                             @Address VARCHAR(200), 
                             @IsRefrigerated BIT, 
                             @Capacity INT, 
                             @QuantityAvailable INT, 
                             @MinimumStockLevel INT, 
                             @MaximumStockLevel INT';


    EXEC sp_executesql @SQL, 
                       @ParamDefinition, 
                       @WarehouseName, 
                       @Address, 
                       @IsRefrigerated, 
                       @Capacity, 
                       @QuantityAvailable, 
                       @MinimumStockLevel, 
                       @MaximumStockLevel;
END;
GO


--ORDER
USE DC_DeliveryCustomer;
GO
CREATE OR ALTER PROCEDURE DC_DELIVERY_CUSTOMER_INSERT_ORDER
    @OrderDate DATE,
    @CustomerID INT,
    @StatusOrder VARCHAR(100),
    @ExpectedDeliveryDate DATE,
    @OrderDetails OrderDetailsType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @CustomerExists INT;

    SET @SQL = N'SELECT @CustomerExists = COUNT(*) FROM dbo.Customer WHERE CustomerID = @CustomerID';
    EXEC sp_executesql @SQL, N'@CustomerID INT, @CustomerExists INT OUTPUT', @CustomerID, @CustomerExists OUTPUT;

    IF @CustomerExists = 0
    BEGIN
        RAISERROR('CustomerID %d does not exist in the DC_DeliveryCustomer database.', 16, 1, @CustomerID);
        RETURN;
    END;

    DECLARE @WarehouseExists INT;
    DECLARE @WarehouseID INT;

    DECLARE cur CURSOR FOR
    SELECT DISTINCT WarehouseID FROM @OrderDetails;

    OPEN cur;

    FETCH NEXT FROM cur INTO @WarehouseID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = N'SELECT @WarehouseExists = COUNT(*) FROM OPENQUERY([serverSQL], 
                      ''SELECT 1 FROM [DC_WarehouseOrder].dbo.Warehouse WHERE WarehouseID = ' + CAST(@WarehouseID AS NVARCHAR(10)) + ''')';
        EXEC sp_executesql @SQL, N'@WarehouseExists INT OUTPUT', @WarehouseExists OUTPUT;

        IF @WarehouseExists = 0
        BEGIN
            RAISERROR('WarehouseID %d does not exist in the DC_WarehouseOrder database.', 16, 1, @WarehouseID);
            CLOSE cur;
            DEALLOCATE cur;
            RETURN;
        END;

        FETCH NEXT FROM cur INTO @WarehouseID;
    END;

    CLOSE cur;
    DEALLOCATE cur;

     SET @SQL = N'INSERT INTO OPENQUERY([serverSQL], 
                     ''SELECT OrderDate, CustomerID, Status, ExpectedDeliveryDate FROM [DC_WarehouseOrder].dbo.[Order]'') 
                     VALUES (@OrderDate, @CustomerID, @StatusOrder, @ExpectedDeliveryDate)';
    EXEC sp_executesql @SQL, N'@OrderDate DATE, @CustomerID INT, @StatusOrder VARCHAR(100), @ExpectedDeliveryDate DATE', 
                       @OrderDate, @CustomerID, @StatusOrder, @ExpectedDeliveryDate;

    SET @SQL = N'SELECT @OrderID = IDENT_CURRENT(''[DC_WarehouseOrder].dbo.[Order]'')';
    DECLARE @OrderID INT;
    EXEC sp_executesql @SQL, N'@OrderID INT OUTPUT', @OrderID OUTPUT;

    IF @OrderID IS NULL
    BEGIN
        RAISERROR('Failed to retrieve the new OrderID.', 16, 1);
        RETURN;
    END;


    DECLARE @OrderDetailSQL NVARCHAR(MAX);
    DECLARE @ProductDescription VARCHAR(200),
            @Quantity INT,
            @PackageDate DATE,
            @DetailStatus VARCHAR(100),
            @Type VARCHAR(50),
            @Dimensions VARCHAR(100),
            @Refrigerated BIT;

    DECLARE detailCursor CURSOR FOR 
    SELECT ProductDescription, Quantity, PackageDate, WarehouseID, Status, Type, Dimensions, Refrigerated
    FROM @OrderDetails;

    OPEN detailCursor;

    FETCH NEXT FROM detailCursor INTO @ProductDescription, @Quantity, @PackageDate, @WarehouseID, @DetailStatus, @Type, @Dimensions, @Refrigerated;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @OrderDetailSQL = N'INSERT INTO OPENQUERY([serverSQL], 
                    ''SELECT OrderID, ProductDescription, Quantity, PackageDate, WarehouseID, Status, Type, Dimensions, Refrigerated FROM [DC_WarehouseOrder].dbo.OrderDetail'') 
                    VALUES (@OrderID, @ProductDescription, @Quantity, @PackageDate, @WarehouseID, @DetailStatus, @Type, @Dimensions, @Refrigerated)';

        EXEC sp_executesql @OrderDetailSQL, 
                           N'@OrderID INT, @ProductDescription VARCHAR(200), @Quantity INT, @PackageDate DATE, @WarehouseID INT, @DetailStatus VARCHAR(100), @Type VARCHAR(50), @Dimensions VARCHAR(100), @Refrigerated BIT',
                           @OrderID, @ProductDescription, @Quantity, @PackageDate, @WarehouseID, @DetailStatus, @Type, @Dimensions, @Refrigerated;

        FETCH NEXT FROM detailCursor INTO @ProductDescription, @Quantity, @PackageDate, @WarehouseID, @DetailStatus, @Type, @Dimensions, @Refrigerated;
    END;

    CLOSE detailCursor;
    DEALLOCATE detailCursor;
END;
GO


--EMPLOYEES
USE DC_DeliveryCustomer;
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


--ROUTES
USE DC_DeliveryCustomer;
GO
CREATE OR ALTER PROCEDURE ORACLE_INSERT_ROUTE
    @RouteName VARCHAR(100),
    @SourceWarehouseID INT,
    @DestinationWarehouseID INT,
    @AssignedEmployeeID INT,
    @Time FLOAT,
    @Distance FLOAT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @RouteNameEscaped NVARCHAR(100);
    DECLARE @Cost FLOAT;

    SET @Cost = (@Distance / 6) * 3.5;

    SET @RouteNameEscaped = REPLACE(@RouteName, '''', '''''');

    SET @SQL = N'BEGIN ROUTES_PACKAGE.INSERT_ROUTE(''' 
                + @RouteNameEscaped + ''', '
                + CAST(@SourceWarehouseID AS NVARCHAR) + ', '
                + CAST(@DestinationWarehouseID AS NVARCHAR) + ', '
                + CAST(@AssignedEmployeeID AS NVARCHAR) + ', '
                + CAST(@Cost AS NVARCHAR) + ', '
                + CAST(@Time AS NVARCHAR) + ', '
                + CAST(@Distance AS NVARCHAR) + '); END;';

    EXEC (@SQL) AT OracleDB;

    PRINT 'Route inserted successfully into Oracle database.';
END;
GO

--CREATE ITINERARY
CREATE OR ALTER PROCEDURE SelectBestRoute
(
    @SourceWarehouseID NUMBER,
    @DestinationWarehouseID NUMBER,
    @Priority VARCHAR2(10) -- 'COST' or 'TIME'
)
AS
BEGIN
    PRINT 'WORKING ON IT';
END;
GO







		



USE DC_WarehouseOrder;
GO
CREATE PROCEDURE DC_WarehouseOrder_INSERT_WAREHOUSE_
    @WarehouseName VARCHAR(100),
    @Address VARCHAR(200),
    @IsRefrigerated BIT,
    @Capacity INT,
    @QuantityAvailable INT,
    @MinimumStockLevel INT,
    @MaximumStockLevel INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert a new warehouse record into the Warehouse table
    INSERT INTO Warehouse (WarehouseName, Address, IsRefrigerated, Capacity, QuantityAvailable, MinimumStockLevel, MaximumStockLevel)
    VALUES (@WarehouseName, @Address, @IsRefrigerated, @Capacity, @QuantityAvailable, @MinimumStockLevel, @MaximumStockLevel);
END;
GO