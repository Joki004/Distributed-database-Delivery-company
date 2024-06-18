USE DC_Warehouse;
GO

CREATE OR ALTER PROCEDURE ADD_WAREHOUSE
    @warehouse_name VARCHAR(100),
    @address VARCHAR(200)
AS
BEGIN
    INSERT INTO Warehouse (warehouse_name, address)
    VALUES (@warehouse_name, @address);
END;
GO