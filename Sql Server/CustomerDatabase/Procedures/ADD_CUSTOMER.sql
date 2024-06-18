USE DC_Customer;
GO

CREATE OR ALTER PROCEDURE ADD_CUSTOMER
    @first_name VARCHAR(100),
	@last_name VARCHAR(100),
    @address VARCHAR(200),
    @email VARCHAR(100),
    @phone_number VARCHAR(15)
AS
BEGIN
    INSERT INTO Customer (first_name, last_name, email, number, address)
    VALUES (@first_name, @last_name, @email, @phone_number, @address);
END;
GO