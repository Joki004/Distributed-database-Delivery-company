USE [DC_Customer];
GO
CREATE OR ALTER PROCEDURE ORACLE_CREATE_BEST_ITINERARY
(
    @SourceWarehouseID INT,
    @DestinationWarehouseID INT,
    @package_id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
	DECLARE @package_details_id INT;
    DECLARE @Priority VARCHAR(100);
    DECLARE @SQLQuery NVARCHAR(MAX);
    DECLARE @ItineraryID INT;
    DECLARE @RouteID INT;
    DECLARE @Cost DECIMAL(10,2);
    DECLARE @Time DECIMAL(10,2);
    DECLARE @Distance DECIMAL(10,2);
    DECLARE @StepNumber INT = 1;
    DECLARE @CurrentWarehouseID INT = @SourceWarehouseID;
    DECLARE @CreationDate DATE = GETDATE();
    DECLARE @DepartureTime DATETIME;
    DECLARE @ArrivalTime DATETIME;
    DECLARE @NextDepartureTime TIME;
    DECLARE @VisitedWarehouses TABLE (WarehouseID INT PRIMARY KEY);
    DECLARE @PreviousArrivalTime DATETIME = NULL;
    DECLARE @NextArrivalTime TIME;
    DECLARE @Routes TABLE (
        RouteID INT, 
        SourceWarehouseID INT, 
        DestinationWarehouseID INT, 
        Cost DECIMAL(10,2), 
        Time DECIMAL(10,2), 
        Distance DECIMAL(10,2), 
        Level INT
    );

	SELECT @package_details_id = package_details_id FROM [DC_Warehouse].dbo.PackageDetails where package_id = @package_id;
    SET @SQLQuery = N'SELECT @Priority = Type FROM [serverSQL].[DC_Warehouse].[dbo].[PackageDetails] WHERE package_details_id = ' + CAST(@package_details_id AS NVARCHAR(10));
    EXEC sp_executesql @SQLQuery, N'@Priority VARCHAR(100) OUTPUT', @Priority OUTPUT;
   

    INSERT INTO @VisitedWarehouses (WarehouseID) VALUES (@SourceWarehouseID);


    SET @SQLQuery = N'SELECT * FROM OPENQUERY([OracleDB], ''SELECT route_id, from_warehouse_id, to_warehouse_id, cost, time, distance FROM SCOTT.ROUTE WHERE from_warehouse_id = ' + CAST(@SourceWarehouseID AS NVARCHAR(10)) + ''')';
    INSERT INTO @Routes (RouteID, SourceWarehouseID, DestinationWarehouseID, Cost, Time, Distance)
    EXEC(@SQLQuery)
    UPDATE @Routes SET Level = 1 WHERE SourceWarehouseID = @SourceWarehouseID;

    WHILE EXISTS (SELECT 1 FROM @Routes WHERE Level > 0)
    BEGIN
        SELECT TOP 1
            @RouteID = RouteID,
            @CurrentWarehouseID = DestinationWarehouseID,
            @Cost = Cost,
            @Time = Time,
            @Distance = Distance
        FROM @Routes
        WHERE Level > 0
        ORDER BY CASE WHEN @Priority = 'Normal' THEN Cost ELSE Time END;

        DELETE FROM @Routes WHERE RouteID = @RouteID;


        DECLARE @ScheduleTemp TABLE (DepartureTime TIME, ArrivalTime TIME);
        SET @SQLQuery = N'SELECT departure_time, arrival_time FROM [OracleDB]..SCOTT.ROUTESCHEDULE WHERE route_id =' + CAST(@RouteID AS NVARCHAR(10));
        INSERT INTO @ScheduleTemp (DepartureTime, ArrivalTime)
        EXEC sp_executesql @SQLQuery;


        IF @PreviousArrivalTime IS NOT NULL
        BEGIN
            SELECT TOP 1 @NextDepartureTime = DepartureTime
            FROM @ScheduleTemp
            WHERE DepartureTime >= CAST(@PreviousArrivalTime AS TIME)
            ORDER BY DepartureTime;

            IF @NextDepartureTime IS NULL
            BEGIN
                SELECT TOP 1 @NextDepartureTime = DepartureTime
                FROM @ScheduleTemp
                ORDER BY DepartureTime;
                SET @DepartureTime = DATEADD(DAY, 1, CAST(CONVERT(VARCHAR, @PreviousArrivalTime, 101) + ' ' + CAST(@NextDepartureTime AS VARCHAR(8)) AS DATETIME));
            END
            ELSE
            BEGIN
                SET @DepartureTime = CAST(CONVERT(VARCHAR, @PreviousArrivalTime, 101) + ' ' + CAST(@NextDepartureTime AS VARCHAR(8)) AS DATETIME);
            END

            SELECT @NextArrivalTime = ArrivalTime FROM @ScheduleTemp WHERE DepartureTime = @NextDepartureTime;
            IF @NextArrivalTime < @NextDepartureTime
            BEGIN
                SET @ArrivalTime = DATEADD(DAY, 1, CAST(CONVERT(VARCHAR, @PreviousArrivalTime, 101) + ' ' + CAST(@NextArrivalTime AS VARCHAR(8)) AS DATETIME));
            END
            ELSE
            BEGIN
                SET @ArrivalTime = CAST(CONVERT(VARCHAR, @PreviousArrivalTime, 101) + ' ' + CAST(@NextArrivalTime AS VARCHAR(8)) AS DATETIME);
            END
        END
        ELSE
        BEGIN
            SELECT TOP 1 @NextDepartureTime = DepartureTime
            FROM @ScheduleTemp
            WHERE DepartureTime >= CAST(GETDATE() AS TIME)
            ORDER BY DepartureTime;

            IF @NextDepartureTime IS NULL
            BEGIN
                SELECT TOP 1 @NextDepartureTime = DepartureTime
                FROM @ScheduleTemp
                ORDER BY DepartureTime;
                SET @DepartureTime = DATEADD(DAY, 1, CAST(CONVERT(VARCHAR, GETDATE(), 101) + ' ' + CAST(@NextDepartureTime AS VARCHAR(8)) AS DATETIME));
            END
            ELSE
            BEGIN
                SET @DepartureTime = CAST(CONVERT(VARCHAR, GETDATE(), 101) + ' ' + CAST(@NextDepartureTime AS VARCHAR(8)) AS DATETIME);
            END

            SELECT @NextArrivalTime = ArrivalTime FROM @ScheduleTemp WHERE DepartureTime = @NextDepartureTime;
            IF @NextArrivalTime < @NextDepartureTime
            BEGIN
                SET @ArrivalTime = DATEADD(DAY, 1, CAST(CONVERT(VARCHAR, GETDATE(), 101) + ' ' + CAST(@NextArrivalTime AS VARCHAR(8)) AS DATETIME));
            END
            ELSE
            BEGIN
                SET @ArrivalTime = CAST(CONVERT(VARCHAR, GETDATE(), 101) + ' ' + CAST(@NextArrivalTime AS VARCHAR(8)) AS DATETIME);
            END
        END

        SET @PreviousArrivalTime = @ArrivalTime;
     


        SET @SQLQuery = N'BEGIN ITINERARY_PACKAGE.INSERT_ITINERARY(' 
                        + CAST(@package_details_id AS NVARCHAR) + ', '
                        + CAST(@RouteID AS NVARCHAR) + ', '
                        + CAST(@StepNumber AS NVARCHAR) + ', '
                        + '''' + CONVERT(VARCHAR, @DepartureTime, 120) + ''', '
                        + '''' + CONVERT(VARCHAR, @ArrivalTime, 120) + '''); END;';
        EXEC (@SQLQuery) AT OracleDB;

        SET @StepNumber = @StepNumber + 1;

        IF @CurrentWarehouseID = @DestinationWarehouseID
        BEGIN
            DECLARE @package_id_check INT;
            SELECT @package_id_check = package_id FROM DC_Warehouse.DBO.PackageDetails WHERE package_details_id = @package_details_id;
            UPDATE DC_Warehouse.DBO.Package
            SET ExpectedDeliveryDate = @PreviousArrivalTime 
            WHERE package_id = @package_id_check;
			 PRINT 'Itinerary inserted successfully into Oracle database.';
            RETURN;
        END

        INSERT INTO @VisitedWarehouses (WarehouseID)
        SELECT @CurrentWarehouseID
        WHERE NOT EXISTS (SELECT 1 FROM @VisitedWarehouses WHERE WarehouseID = @CurrentWarehouseID);

    
        SET @SQLQuery = N'SELECT route_id, from_warehouse_id, to_warehouse_id, cost, time, distance, 1 AS Level FROM [OracleDB]..SCOTT.ROUTE WHERE from_warehouse_id = ' + CAST(@CurrentWarehouseID AS NVARCHAR(10));
        INSERT INTO @Routes (RouteID, SourceWarehouseID, DestinationWarehouseID, Cost, Time, Distance, Level)
        EXEC sp_executesql @SQLQuery;
    END;

    RAISERROR('No route found from source to destination.', 16, 1);
END;
GO


USE [DC_Customer];
GO
CREATE OR ALTER PROCEDURE GET_ORDER_ITINERARY
(
    @package_details_id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Itinerary TABLE 
    (
        StepNumber INT,
        RouteID INT,
        DepartureTime DATETIME,
        ArrivalTime DATETIME,
        SourceWarehouseName VARCHAR(100),
        DestinationWarehouseName VARCHAR(100)
    );

    -- SQL to fetch itinerary details from OracleDB
    SET @SQL = N'
        SELECT 
            IT.StepNumber,
            IT.RouteID,
            IT.DepartureTime,
            IT.ArrivalTime,
            SW.warehouse_name AS SourceWarehouseName,
            DW.warehouse_name AS DestinationWarehouseName
        FROM 
            OPENQUERY([OracleDB], 
                ''SELECT 
                    I.Step_Number AS StepNumber,
                    I.Route_ID AS RouteID,
                    I.Departure_Date AS DepartureTime,
                    I.Arrival_Date AS ArrivalTime,
                    R.From_Warehouse_ID,
                    R.To_Warehouse_ID
                FROM 
                    ITINERARY I
                JOIN 
                    ROUTE R ON I.Route_ID = R.Route_ID
                WHERE 
                    I.package_details_id = ''''' + CAST(@package_details_id AS NVARCHAR) + '''''
                ORDER BY 
                    I.Step_Number'') IT
        JOIN 
            [serverSQL].[DC_Warehouse].[dbo].[Warehouse] SW ON IT.From_Warehouse_ID = SW.warehouse_id
        JOIN 
            [serverSQL].[DC_Warehouse].[dbo].[Warehouse] DW ON IT.To_Warehouse_ID = DW.warehouse_id
    ';

    INSERT INTO @Itinerary (StepNumber, RouteID, DepartureTime, ArrivalTime, SourceWarehouseName, DestinationWarehouseName)
    EXEC sp_executesql @SQL;

    -- Select the itinerary for the calling procedure
    SELECT * FROM @Itinerary ORDER BY StepNumber;
END;
GO

USE [DC_Customer];
GO
CREATE OR ALTER PROCEDURE PRINT_ORDER_ITINERARY
(
    @package_details_id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @StepNumber INT;
    DECLARE @RouteID INT;
    DECLARE @DepartureTime DATETIME;
    DECLARE @ArrivalTime DATETIME;
    DECLARE @SourceWarehouseName VARCHAR(100);
    DECLARE @DestinationWarehouseName VARCHAR(100);

    -- SQL to fetch itinerary details from OracleDB
    SET @SQL = N'
        SELECT 
            IT.StepNumber,
            IT.RouteID,
            IT.DepartureTime,
            IT.ArrivalTime,
            SW.warehouse_name AS SourceWarehouseName,
            DW.warehouse_name AS DestinationWarehouseName
        FROM 
            OPENQUERY([OracleDB], 
                ''SELECT 
                    I.Step_Number AS StepNumber,
                    I.Route_ID AS RouteID,
                    I.Departure_Date AS DepartureTime,
                    I.Arrival_Date AS ArrivalTime,
                    R.From_Warehouse_ID,
                    R.To_Warehouse_ID
                FROM 
                    ITINERARY I
                JOIN 
                    ROUTE R ON I.Route_ID = R.Route_ID
                WHERE 
                    I.package_details_id = ''''' + CAST(@package_details_id AS NVARCHAR) + '''''
                ORDER BY 
                    I.Step_Number'') IT
        JOIN 
            [serverSQL].[DC_Warehouse].[dbo].[Warehouse] SW ON IT.From_Warehouse_ID = SW.warehouse_id
        JOIN 
            [serverSQL].[DC_Warehouse].[dbo].[Warehouse] DW ON IT.To_Warehouse_ID = DW.warehouse_id
    ';

    -- Create a temporary table to store the result
    CREATE TABLE #Itinerary
    (
        StepNumber INT,
        RouteID INT,
        DepartureTime DATETIME,
        ArrivalTime DATETIME,
        SourceWarehouseName VARCHAR(100),
        DestinationWarehouseName VARCHAR(100)
    );

    -- Insert the result into the temporary table
    INSERT INTO #Itinerary (StepNumber, RouteID, DepartureTime, ArrivalTime, SourceWarehouseName, DestinationWarehouseName)
    EXEC sp_executesql @SQL;

    -- Declare the cursor for the temporary table
    DECLARE itinerary_cursor CURSOR FOR
    SELECT 
        StepNumber,
        RouteID,
        DepartureTime,
        ArrivalTime,
        SourceWarehouseName,
        DestinationWarehouseName
    FROM #Itinerary;

    OPEN itinerary_cursor;

    FETCH NEXT FROM itinerary_cursor INTO 
        @StepNumber,
        @RouteID,
        @DepartureTime,
        @ArrivalTime,
        @SourceWarehouseName,
        @DestinationWarehouseName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Step Number: ' + CAST(@StepNumber AS VARCHAR(10));
        PRINT 'Route ID: ' + CAST(@RouteID AS VARCHAR(10));
        PRINT 'Departure Time: ' + CONVERT(VARCHAR, @DepartureTime, 120);
        PRINT 'Arrival Time: ' + CONVERT(VARCHAR, @ArrivalTime, 120);
        PRINT 'Source Warehouse: ' + @SourceWarehouseName;
        PRINT 'Destination Warehouse: ' + @DestinationWarehouseName;
        PRINT '-----------------------------';

        FETCH NEXT FROM itinerary_cursor INTO 
            @StepNumber,
            @RouteID,
            @DepartureTime,
            @ArrivalTime,
            @SourceWarehouseName,
            @DestinationWarehouseName;
    END;

    CLOSE itinerary_cursor;
    DEALLOCATE itinerary_cursor;

    -- Drop the temporary table
    DROP TABLE #Itinerary;
END;
GO







