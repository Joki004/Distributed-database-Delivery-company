BEGIN DISTRIBUTED TRANSACTION;

DECLARE @first_name NVARCHAR(50) = 'Johnny';
DECLARE @last_name NVARCHAR(50) = 'Donny';
DECLARE @address NVARCHAR(100) = '123 Main St, Anytown';
DECLARE @number NVARCHAR(20) = '555-123-4567';
DECLARE @email NVARCHAR(100) = 'johndoe@example.com';
DECLARE @customer_id INT;

EXEC [DC_Customer].dbo.ADD_CUSTOMER @first_name, @Last_name, @address, @email, @number

SET @customer_id = SCOPE_IDENTITY();

SELECT @customer_id AS 'Added Customer ID';
SELECT * From Customer

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
ELSE
    ROLLBACK TRANSACTION;
