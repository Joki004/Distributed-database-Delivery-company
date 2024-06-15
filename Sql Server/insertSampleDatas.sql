USE DC_DeliveryCustomer;
GO
--CUSTOMERS
EXEC DC_DELIVERY_CUSTOMER_INSERT_CUSTOMER 'Alice', 'Johnson','alice.johnson@example.com', '123-456-7890','789 Pine Street';
EXEC DC_DELIVERY_CUSTOMER_INSERT_CUSTOMER 'John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Main St, Montpellier';
EXEC DC_DELIVERY_CUSTOMER_INSERT_CUSTOMER 'Jane', 'Smith', 'jane.smith@example.com', '987-654-3210', '456 High St, Paris';
GO

--WAREHOUSES
EXEC [dbo].[DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE] 'Central Warehouse', '456 Industrial Rd', 1,10000, 5000,100,10000;
EXEC [dbo].[DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE] 'Toulouse Warehouse', '456 Toulouse St, Toulouse', 0, 1500, 1200, 150, 1500;
EXEC [dbo].[DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE] 'Marseille Warehouse', '789 Marseille St, Marseille', 1, 1800, 1300, 180, 1800
EXEC [dbo].[DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE] 'Lyon Warehouse', '101 Lyon Rd, Lyon', 0, 2000, 1500, 200, 2000;
EXEC [dbo].[DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE] 'Nice Warehouse', '202 Nice St, Nice', 1, 1700, 1200, 170, 1700;
EXEC [dbo].[DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE] 'Bordeaux Warehouse', '303 Bordeaux Rd, Bordeaux', 0, 1600, 1300, 160, 1600;
EXEC [dbo].[DC_DELIVERY_CUSTOMER_INSERT_WAREHOUSE] 'Nantes Warehouse', '404 Nantes St, Nantes', 1, 1400, 1100, 140, 1400;
GO

--ORDERS AND ORDERSDETAILS
DECLARE @TodayDate DATE = GETDATE();
DECLARE @OrderDetails OrderDetailsType;
INSERT INTO @OrderDetails (ProductDescription, Quantity, PackageDate, WarehouseID, Status,Type, Dimensions, Refrigerated)
VALUES ('Samsung Galaxy S24', 10, GETDATE(), 1, 'Pending','Standard', '10x10x10', 0),
       ('Iphone 12', 5, GETDATE(), 2, 'Pending','Priority', '20x20x20', 1);
EXEC DC_DELIVERY_CUSTOMER_INSERT_ORDER @TodayDate, 1, 'Pending',@ExpectedDeliveryDate ,@OrderDetails;

DECLARE @OrderDetails2 OrderDetailsType;
INSERT INTO @OrderDetails2 (ProductDescription, Quantity, PackageDate, WarehouseID, Status,Type, Dimensions, Refrigerated)
VALUES ('Nike', 2,@TodayDate, 1, 'Pending','Standard', '10x10x10', 0),
       ('Addidas', 9, @TodayDate, 2, 'Pending','Priority', '20x20x20', 0);
EXEC DC_DELIVERY_CUSTOMER_INSERT_ORDER @TodayDate, 2, 'Pending',@ExpectedDeliveryDate ,@OrderDetails2;
GO

--DELIVERIES
DECLARE @ExpectedDeliveryDate DATE = DATEADD(DAY, 7, GETDATE())
EXEC DC_DELIVERY_CUSTOMER_INSERT_DELIVERY 1,6,'Penging',@ExpectedDeliveryDate;
EXEC DC_DELIVERY_CUSTOMER_INSERT_DELIVERY 2,7,'Penging',@ExpectedDeliveryDate;
GO

--EMPLOYEE
EXEC [dbo].[ORACLE_INSERT_EMPLOYEE] 'John Manager', 'Logistics Manager';
EXEC [dbo].[ORACLE_INSERT_EMPLOYEE] 'Jane Supervisor', 'Warehouse Supervisor';
GO

-- ROUTES
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Central to Toulouse', @SourceWarehouseID = 1, @DestinationWarehouseID = 2, @AssignedEmployeeID = 101, @Time = 3.5, @Distance = 350;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Toulouse to Marseille', @SourceWarehouseID = 2, @DestinationWarehouseID = 3, @AssignedEmployeeID = 102, @Time = 4.0, @Distance = 400;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Marseille to Lyon', @SourceWarehouseID = 3, @DestinationWarehouseID = 4, @AssignedEmployeeID = 103, @Time = 5.0, @Distance = 500;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Lyon to Nice', @SourceWarehouseID = 4, @DestinationWarehouseID = 5, @AssignedEmployeeID = 104, @Time = 6.0, @Distance = 600;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Nice to Bordeaux', @SourceWarehouseID = 5, @DestinationWarehouseID = 6, @AssignedEmployeeID = 105, @Time = 2.5, @Distance = 250;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Bordeaux to Nantes', @SourceWarehouseID = 6, @DestinationWarehouseID = 7, @AssignedEmployeeID = 106, @Time = 3.0, @Distance = 300;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Nantes to Central', @SourceWarehouseID = 7, @DestinationWarehouseID = 1, @AssignedEmployeeID = 107, @Time = 4.5, @Distance = 450;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Central to Marseille', @SourceWarehouseID = 1, @DestinationWarehouseID = 3, @AssignedEmployeeID = 108, @Time = 4.0, @Distance = 400;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Toulouse to Lyon', @SourceWarehouseID = 2, @DestinationWarehouseID = 4, @AssignedEmployeeID = 109, @Time = 5.5, @Distance = 550;
EXEC ORACLE_INSERT_ROUTE @RouteName = 'Marseille to Bordeaux', @SourceWarehouseID = 3, @DestinationWarehouseID = 6, @AssignedEmployeeID = 110, @Time = 6.0, @Distance = 600;
GO





select * from Customer;
select * from Delivery;
SELECT * FROM DC_WarehouseOrder.DBO."Order"

USE DC_WarehouseOrder;
GO
-- Insert sample data into Warehouse table
USE DC_DeliveryCustomer
GO


USE DC_WarehouseOrder;

USE DC_WarehouseOrder;
GO

select * from DC_WarehouseOrder.DBO."Order" where OrderID = 6 and CustomerID = 1;
select * from Warehouse;
select * from "Order";
select * from OrderDetail;
DELETE FROM "Order" WHERE CustomerID = 1;
DELETE FROM OrderDetail WHERE WarehouseID = 1;

SELECT 
    c.first_name, 
    c.last_name, 
    o.OrderID, 
    o.OrderDate, 
    o.Status, 
    o.ExpectedDeliveryDate
FROM 
    [DC_DeliveryCustomer].dbo.Customer AS c
JOIN 
    [DC_WarehouseOrder].dbo.[Order] AS o
ON 
    c.CustomerID = o.CustomerID

GO


------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------ORACLE----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO [OracleDB]..SCOTT.ROUTE 
(RouteID, RouteName, SourceWarehouseID, DestinationWarehouseID, AssignedEmployeeID, PlannedDate)
SELECT 
    NEWID(), 
    'Route 1', 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Paris Warehouse'), 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Toulouse Warehouse'), 
    (SELECT EmployeeID FROM [OracleDB]..SCOTT.EMPLOYEE WHERE EmployeeName = 'John Manager'), 
    CONVERT(DATE, '2024-06-10', 120)
FROM (SELECT 1 AS DUMMY) AS SingleRow; 


-- Insert Route 2
INSERT INTO [OracleDB]..SCOTT.ROUTE 
(RouteID, RouteName, SourceWarehouseID, DestinationWarehouseID, AssignedEmployeeID, PlannedDate)
SELECT 
    NEWID(), 
    'Route 2', 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Toulouse Warehouse'), 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Marseille Warehouse'), 
    (SELECT EmployeeID FROM [OracleDB]..SCOTT.EMPLOYEE WHERE EmployeeName = 'Jane Supervisor'), 
    CONVERT(DATE, '2024-06-11', 120)
FROM (SELECT 1 AS DUMMY) AS SingleRow; 



-- Insert multiple rows into Oracle Itinerary table
INSERT INTO [OracleDB]..SCOTT.ITINERARY 
(ItineraryID, OrderDetailID, CreatedByEmployeeID, CreationDate)
SELECT 
    NEWID(), 
    (SELECT OrderDetailID FROM [DC_WarehouseOrder].[dbo].[OrderDetail] WHERE ProductDescription = 'Product A'), 
    (SELECT EmployeeID FROM [OracleDB]..SCOTT.EMPLOYEE WHERE EmployeeName = 'John Manager'), 
    '2024-06-10'
UNION ALL
SELECT 
    NEWID(), 
    (SELECT OrderDetailID FROM [DC_WarehouseOrder].[dbo].[OrderDetail] WHERE ProductDescription = 'Product B'), 
    (SELECT EmployeeID FROM [OracleDB]..SCOTT.EMPLOYEE WHERE EmployeeName = 'Jane Supervisor'), 
    '2024-06-11';



-- Insert multiple rows into Oracle ItineraryDetail table
INSERT INTO [OracleDB]..SCOTT.ITINERARYDETAIL 
(ItineraryDetailID, ItineraryID, FromWarehouseID, ToWarehouseID, DepartureDate, ArrivalDate, Cost, Distance, Time)
SELECT 
    NEWID(), 
    (SELECT ItineraryID FROM [OracleDB]..SCOTT.ITINERARY WHERE OrderDetailID = 
        (SELECT OrderDetailID FROM [DC_WarehouseOrder].[dbo].[OrderDetail] WHERE ProductDescription = 'Product A')), 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Paris Warehouse'), 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Toulouse Warehouse'), 
    '2024-06-11', '2024-06-12', 100.00, 200.00, 5.00
UNION ALL
SELECT 
    NEWID(), 
    (SELECT ItineraryID FROM [OracleDB]..SCOTT.ITINERARY WHERE OrderDetailID = 
        (SELECT OrderDetailID FROM [DC_WarehouseOrder].[dbo].[OrderDetail] WHERE ProductDescription = 'Product B')), 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Toulouse Warehouse'), 
    (SELECT WarehouseID FROM [DC_WarehouseOrder].[dbo].[Warehouse] WHERE WarehouseName = 'Marseille Warehouse'), 
    '2024-06-12', '2024-06-13', 150.00, 300.00, 6.00;



