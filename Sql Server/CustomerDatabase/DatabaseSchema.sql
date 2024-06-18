
--DATABASE: DC_Customer

IF DB_ID('DC_Customer') IS NOT NULL
BEGIN
    ALTER DATABASE DC_Customer SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DC_Customer;
END
GO

CREATE DATABASE DC_Customer;
GO

USE DC_Customer;
GO

IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL DROP TABLE dbo.Customer;
GO

CREATE TABLE Customer (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(50),
    number NVARCHAR(20),
    address NVARCHAR(255)
);
GO