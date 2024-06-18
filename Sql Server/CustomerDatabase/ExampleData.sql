--EXAMPLE DATA -- CUSTOMER DATABASE

--Customer

USE DC_Customer;
GO

EXEC ADD_CUSTOMER 'Adam', 'Malysz', '456 Industrial Rd, Warsaw', 'adam.malysz@gmail.com', '621324546';
EXEC ADD_CUSTOMER 'Joram', 'Fabianski', '123 Piotrkowska, Lodz', 'Joram.fabianski13@gmail.com', '543785321';
EXEC ADD_CUSTOMER 'Alice', 'Johnson', '789 Pine Street', 'alice.johnson@example.com', '875426519';
EXEC ADD_CUSTOMER 'John', 'Doe', '123 Main St, Montpellier', 'john.doe@example.com', '543426789';
EXEC ADD_CUSTOMER 'Jane', 'Smith', '456 High St, Paris', 'jane.smith@example.com','754843543';

SELECT * FROM Customer;
 
EXEC PRINT_CUSTOMER_INFORMATION '1';