USE DC_WarehouseOrder;
GO

-- Create trigger for Order table
CREATE TRIGGER trg_OrderChange
ON [Order]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle insert operations
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO OrderHistory (OrderID, FromWarehouseID, ToWarehouseID, DepartureDate, ArrivalDate)
        SELECT 
            i.OrderID,
            NULL AS FromWarehouseID,
            NULL AS ToWarehouseID,
            NULL AS DepartureDate,
            GETDATE() AS ArrivalDate
        FROM inserted i;
    END

    -- Handle update operations
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        IF UPDATE(Status)
        BEGIN
            INSERT INTO OrderHistory (OrderID, FromWarehouseID, ToWarehouseID, DepartureDate, ArrivalDate)
            SELECT 
                i.OrderID,
                NULL AS FromWarehouseID,
                NULL AS ToWarehouseID,
                NULL AS DepartureDate,
                GETDATE() AS ArrivalDate
            FROM inserted i
            JOIN deleted d ON i.OrderID = d.OrderID
            WHERE i.Status <> d.Status;
        END
    END

    -- Handle delete operations
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO OrderHistory (OrderID, FromWarehouseID, ToWarehouseID, DepartureDate, ArrivalDate)
        SELECT 
            d.OrderID,
            NULL AS FromWarehouseID,
            NULL AS ToWarehouseID,
            GETDATE() AS DepartureDate,
            NULL AS ArrivalDate
        FROM deleted d;
    END
END;
GO


-- Create trigger for OrderDetail table
CREATE TRIGGER trg_OrderDetailChange
ON OrderDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle insert operations
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO OrderHistory (OrderID, FromWarehouseID, ToWarehouseID, DepartureDate, ArrivalDate)
        SELECT 
            i.OrderID,
            NULL AS FromWarehouseID,
            i.WarehouseID AS ToWarehouseID,
            NULL AS DepartureDate,
            GETDATE() AS ArrivalDate
        FROM inserted i;
    END

    -- Handle update operations
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        IF UPDATE(WarehouseID)
        BEGIN
            INSERT INTO OrderHistory (OrderID, FromWarehouseID, ToWarehouseID, DepartureDate, ArrivalDate)
            SELECT 
                i.OrderID,
                d.WarehouseID AS FromWarehouseID,
                i.WarehouseID AS ToWarehouseID,
                GETDATE() AS DepartureDate,
                NULL AS ArrivalDate
            FROM inserted i
            JOIN deleted d ON i.OrderID = d.OrderID
            WHERE i.WarehouseID <> d.WarehouseID;
        END
    END

    -- Handle delete operations
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO OrderHistory (OrderID, FromWarehouseID, ToWarehouseID, DepartureDate, ArrivalDate)
        SELECT 
            d.OrderID,
            d.WarehouseID AS FromWarehouseID,
            NULL AS ToWarehouseID,
            GETDATE() AS DepartureDate,
            NULL AS ArrivalDate
        FROM deleted d;
    END
END;
GO

