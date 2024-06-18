USE DC_Customer;
GO
--EXEC [dbo].[ORACLE_INSERT_EMPLOYEE]   EmployeeName, Position 
EXEC [dbo].[ORACLE_INSERT_EMPLOYEE] 'John Doe', 'Logistics Manager';
EXEC [dbo].[ORACLE_INSERT_EMPLOYEE] 'Jan  Sankowski', 'Warehouse Supervisor';
EXEC [dbo].[ORACLE_INSERT_EMPLOYEE] 'Pawel Piotrkowska', 'Driver';
EXEC [dbo].[ORACLE_INSERT_EMPLOYEE] 'Jakub Kusmiez', 'Driver';
GO

-- ROUTES
-- EXEC ORACLE_INSERT_ROUTE RouteName,
--							SourceWarehouseName 
--						    DestinationWarehouseName,
--							AssignedEmployeeID,
--							VehicleID ,
--							Time ,
--							Distance ,
--							Schedule
EXEC ORACLE_INSERT_ROUTE 'Warsaw to Lodz', 'Warsaw', 'Lodz', 1, 0, 2.5, 120.0,
    '[{"Departure":"08:00"}, {"Departure":"15:00"}, {"Departure":"21:00"}]';
EXEC ORACLE_INSERT_ROUTE 'Lodz to Krakow', 'Lodz', 'Krakow', 2, 0, 3.0, 135.0,
    '[{"Departure":"08:00"}, {"Departure":"15:00"}, {"Departure":"21:00"}]';
EXEC ORACLE_INSERT_ROUTE 'Krakow to Gdansk', 'Krakow', 'Gdansk', 3, 0, 4.0, 200.0,
    '[{"Departure":"08:00"}, {"Departure":"15:00"}, {"Departure":"21:00"}]';
EXEC ORACLE_INSERT_ROUTE 'Gdansk to Torun', 'Gdansk', 'Torun', 4, 0, 1.5, 90.0,
    '[{"Departure":"08:00"}, {"Departure":"15:00"}, {"Departure":"21:00"}]';
EXEC ORACLE_INSERT_ROUTE 'Torun to Gdynia', 'Torun', 'Gdynia', 5, 0, 2.0, 100.0,
    '[{"Departure":"08:00"}, {"Departure":"15:00"}, {"Departure":"21:00"}]';
EXEC ORACLE_INSERT_ROUTE 'Gdynia to Rzeszow', 'Gdynia', 'Rzeszow', 6, 0, 5.0, 300.0,
    '[{"Departure":"08:00"}, {"Departure":"15:00"}, {"Departure":"21:00"}]';
EXEC ORACLE_INSERT_ROUTE 'Rzeszow to Warsaw', 'Rzeszow', 'Warsaw', 7, 0, 3.5, 180.0,
    '[{"Departure":"08:00"}, {"Departure":"15:00"}, {"Departure":"21:00"}]';
GO


-- EXEC [dbo].GET_ORDER_ITINERARY package_details_id;
EXEC [dbo].GET_ORDER_ITINERARY 1;

-- EXEC PRINT_ORDER_ITINERARY package_details_id
EXEC PRINT_ORDER_ITINERARY  1;


