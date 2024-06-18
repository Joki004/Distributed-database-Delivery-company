--ROUTES
USE DC_Customer;
GO
CREATE OR ALTER PROCEDURE ORACLE_INSERT_ROUTE
    @RouteName VARCHAR(100),
    @SourceWarehouseName VARCHAR(100),
    @DestinationWarehouseName VARCHAR(100),
    @AssignedEmployeeID INT,
	@VehicleID INT,
    @Time FLOAT,
    @Distance FLOAT,
	@Schedule NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @RouteNameEscaped NVARCHAR(100);
    DECLARE @Cost FLOAT;
	DECLARE @SourceWarehouseID INT;
	DECLARE @DestinationWarehouseID INT;
	DECLARE @SQLQuery NVARCHAR(MAX);
	DECLARE @Temp TABLE (WarehouseID INT);
	DECLARE @RouteID INT;
    DECLARE @DepartureTime NVARCHAR(5);
    DECLARE @ArrivalTime NVARCHAR(5);
    DECLARE @JSON NVARCHAR(MAX);


	SET @SourceWarehouseID = -1;
    SET @DestinationWarehouseID = -1;

	
	SET @SQL = N'SELECT warehouse_id FROM OPENQUERY([serverSQL], ''SELECT warehouse_id FROM [DC_Warehouse].dbo.Warehouse WHERE warehouse_name = ''''' + @SourceWarehouseName + ''''''')';
    INSERT INTO @Temp EXEC(@SQL);

    SELECT @SourceWarehouseID = WarehouseID FROM @Temp;


	IF @SourceWarehouseID = -1
    BEGIN
        RAISERROR('Source Warehouse not found: %s', 16, 1, @SourceWarehouseName);
        RETURN;
    END

	DELETE FROM @Temp
    SET @SQL = 'SELECT warehouse_id FROM OPENQUERY([serverSQL], ''SELECT warehouse_id FROM [DC_Warehouse].dbo.Warehouse WHERE warehouse_name = ''''' + @DestinationWarehouseName + ''''''')';
    EXEC sp_executesql @SQL, N'@DestinationWarehouseID INT OUTPUT', @DestinationWarehouseID OUTPUT;
	INSERT INTO @Temp EXEC(@SQL);

    SELECT @DestinationWarehouseID = WarehouseID FROM @Temp;
 
	 IF @DestinationWarehouseID = -1
    BEGIN
        RAISERROR('Destination Warehouse not found: %s', 16, 1, @DestinationWarehouseName);
        RETURN;
    END
	
	SET @Cost = (@Distance / 6) * 3.5;

   
    SET @RouteNameEscaped = REPLACE(@RouteName, '''', '''''');

   
    SET @SQL = N'BEGIN ROUTES_PACKAGE.INSERT_ROUTE(''' 
                + @RouteNameEscaped + ''', '
                + CAST(@SourceWarehouseID AS NVARCHAR) + ', '
                + CAST(@DestinationWarehouseID AS NVARCHAR) + ', '
                + CAST(@AssignedEmployeeID AS NVARCHAR) + ', '
				+ COALESCE(CAST(@VehicleID AS NVARCHAR), 'NULL') + ', '
                + CAST(@Cost AS NVARCHAR) + ', '
                + CAST(@Time AS NVARCHAR) + ', '
                + CAST(@Distance AS NVARCHAR) + '); END;';

    EXEC (@SQL) AT OracleDB;

	 SET @SQL = N'SELECT route_id FROM OPENQUERY([OracleDB], '
             + N'''SELECT route_id FROM Route ORDER BY route_id DESC FETCH FIRST 1 ROW ONLY'')';
    INSERT INTO @Temp EXEC(@SQL);
    SELECT @RouteID = WarehouseID FROM @Temp;
	 DECLARE @Schedules TABLE (DepartureTime NVARCHAR(5), ArrivalTime NVARCHAR(5));
    INSERT INTO @Schedules (DepartureTime, ArrivalTime)
    SELECT ScheduleValue, DATEADD(MINUTE, @Time * 60, CAST(ScheduleValue AS TIME))
    FROM OPENJSON(@Schedule)
    WITH (
        ScheduleValue NVARCHAR(50) '$.Departure'
    );
	select * from @Schedules;
    DECLARE ScheduleCursor CURSOR FOR
        SELECT DepartureTime, ArrivalTime FROM @Schedules;

    OPEN ScheduleCursor;
    FETCH NEXT FROM ScheduleCursor INTO @DepartureTime, @ArrivalTime;

    WHILE @@FETCH_STATUS = 0
    BEGIN
       SET @SQL =N'BEGIN ROUTES_PACKAGE.INSERT_ROUTE_SCHEDULE(' 
                    + CAST(@RouteID AS NVARCHAR) + ', '
                    + '''' + @DepartureTime + ''', '
                    + '''' + @ArrivalTime + '''); END;';
        EXEC (@SQL) AT OracleDB;

        FETCH NEXT FROM ScheduleCursor INTO @DepartureTime, @ArrivalTime;
    END;

    CLOSE ScheduleCursor;
    DEALLOCATE ScheduleCursor;

    PRINT 'Route inserted successfully into Oracle database.';
END;
GO