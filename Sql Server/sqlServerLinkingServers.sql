--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------ORACLE-----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.name = 'OracleDB')
    EXEC sp_dropserver 'OracleDB', 'droplogins';
GO
-- Create the linked server
EXEC sp_addlinkedserver 
    @server = 'OracleDB', 
    @srvproduct = 'Oracle', 
    @provider = 'OraOLEDB.Oracle', 
    @datasrc = 'pd19'; 
GO
-- Configure the linked server login
EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'OracleDB', 
    @useself = 'false', 
    @locallogin = NULL, 
    @rmtuser = 'SCOTT', 
    @rmtpassword = '12345';
GO

-- Test the linked server
EXEC sp_testlinkedserver N'OracleDB';
GO

SELECT * FROM OracleDB..SCOTT.EMPLOYEE;


--OPENROWSET
--Set Ad Hoc Distributed Queries:
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

EXEC sp_MSset_oledb_prop N'OraOLEDB.Oracle', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'OraOLEDB.Oracle', N'DynamicParameters', 1;
GO


SELECT * FROM OPENROWSET(
   'OraOLEDB.Oracle',
   'pd19';'SCOTT';'12345',
   'SELECT * FROM EMPLOYEE'
) AS EMPLOYEE;
GO


SELECT * FROM OPENQUERY(OracleDB, 'SELECT * FROM EMPLOYEE');


--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------SQL SERVER-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

USE [master]  
GO 


IF EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.name = 'serverSQL')
    EXEC sp_dropserver 'serverSQL', 'droplogins';
GO

EXEC sp_addlinkedserver
   @server=N'serverSQL',
   @srvproduct=N'',
   @provider=N'SQLOLEDB',
   @datasrc=N'JORAM_PC\MSSQLSERVER2';
GO


EXEC master.dbo.sp_addlinkedsrvlogin   
    @rmtsrvname = N'serverSQL',   
    @locallogin = NULL,   
    @useself = N'False',   
    @rmtuser = N'sa',   
    @rmtpassword = 'praktyka';
GO

sp_addlinkedsrvlogin
     @rmtsrvname = N'serverSQL'
     , @useself = 'true' 
     , @locallogin =  N'sa';

-- Test the linked server connection
EXEC sp_testlinkedserver N'serverSQL';

SELECT name FROM serverSQL.master.sys.databases;  
GO
SELECT * FROM serverSQL.DC_DeliveryCustomer.dbO.Customer;

--OPENROWSET
SELECT * FROM OPENROWSET('SQLNCLI', 'Server=JORAM_PC;Trusted_Connection=yes;', 'SELECT * FROM Customer')
