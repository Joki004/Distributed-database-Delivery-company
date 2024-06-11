------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------DC_DeliveryCustomer---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

USE DC_DeliveryCustomer;
GO

-- Insert sample data into Customer table
INSERT INTO dbo.Customer (first_name, last_name, email, number, address)
VALUES 
('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Main St, Montpellier'),
('Jane', 'Smith', 'jane.smith@example.com', '987-654-3210', '456 High St, Paris');
GO

-- Assuming Order and OrderDetail tables exist and have appropriate UNIQUEIDENTIFIER primary keys
-- Insert sample data into Delivery table
INSERT INTO dbo.Delivery (OrderID, DeliveryDate, CustomerID, Status, OrderDetailID)
VALUES 
(NEWID(), '2024-06-15', (SELECT CustomerID FROM dbo.Customer WHERE first_name = 'John' AND last_name = 'Doe'), 'Pending', NEWID()),
(NEWID(), '2024-06-16', (SELECT CustomerID FROM dbo.Customer WHERE first_name = 'Jane' AND last_name = 'Smith'), 'Pending', NEWID());
GO

select * from Customer;
select * from Delivery;

------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------DC_WarehouseOrder	----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
USE DC_WarehouseOrder;
GO
-- Insert sample data into Warehouse table
INSERT INTO Warehouse (WarehouseName, Address, IsRefrigerated, Capacity, QuantityAvailable, MinimumStockLevel, MaximumStockLevel)
VALUES 
('Paris Warehouse', '123 Paris St, Paris', 0, 2000, 1500, 200, 2000),
('Toulouse Warehouse', '456 Toulouse St, Toulouse', 0, 1500, 1200, 150, 1500),
('Marseille Warehouse', '789 Marseille St, Marseille', 1, 1800, 1300, 180, 1800);
GO
-- Insert Orders
-- Use existing UUIDs for CustomerID from SQL Server 1 for demonstration
INSERT INTO "Order" (OrderDate, CustomerID, Status, ExpectedDeliveryDate)
VALUES 
('2024-06-10', (SELECT CustomerID FROM [DC_DeliveryCustomer].dbo.Customer WHERE first_name = 'John' AND last_name = 'Doe'), 'Pending', '2024-06-15'),
('2024-06-11', (SELECT CustomerID FROM [DC_DeliveryCustomer].dbo.Customer WHERE first_name = 'Jane' AND last_name = 'Smith'), 'Pending', '2024-06-16');
GO
-- Insert Order Details
INSERT INTO OrderDetail (OrderID, ProductDescription, Quantity, PackageDate, WarehouseID, Status, Type, Dimensions, Refrigerated)
VALUES 
((SELECT OrderID FROM "Order" WHERE CustomerID = (SELECT CustomerID FROM [DC_DeliveryCustomer].dbo.Customer WHERE first_name = 'John' AND last_name = 'Doe')), 'Product A', 10, '2024-06-11', (SELECT WarehouseID FROM Warehouse WHERE WarehouseName = 'Paris Warehouse'), 'Pending', 'Priority', '10x10x10', 0),
((SELECT OrderID FROM "Order" WHERE CustomerID = (SELECT CustomerID FROM [DC_DeliveryCustomer].dbo.Customer WHERE first_name = 'Jane' AND last_name = 'Smith')), 'Product B', 5, '2024-06-12', (SELECT WarehouseID FROM Warehouse WHERE WarehouseName = 'Toulouse Warehouse'), 'Pending', 'Standard', '20x20x20', 0);
GO

select * from Warehouse;
select * from "Order";
select * from OrderDetail;

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



